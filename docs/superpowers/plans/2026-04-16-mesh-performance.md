# Mesh Connectivity and Performance Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform RouteRelay into a high-performance, multi-peer mesh network by implementing concurrent L2CAP connections on Android, offloading mesh logic to a dedicated Dart Isolate, and adding priority-based message queueing with adaptive voice feedback.

**Architecture:** 
- **Native (Kotlin):** Refactor L2CAP plugin to use a `ConcurrentHashMap` for socket pooling and an `EventChannel` for streaming data back to Flutter.
- **Dart (Mesh Isolate):** A dedicated Isolate handling Protobuf processing, routing, and deduplication.
- **Communication:** Use `TransferableTypedData` for zero-copy memory movement between Isolates.
- **Network Intelligence:** Implementation of a `PriorityQueue` and a feedback loop to `AudioService` for adaptive bitrate control.

**Tech Stack:** Flutter, Dart (Isolates, Typed Data), Kotlin (Coroutines, EventChannel, BluetoothSocket), Protobuf.

---

### Task 1: Native Multi-Peer L2CAP Support

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/routerelay/L2CapPlugin.kt`
- Modify: `lib/services/ble_service.dart`

- [ ] **Step 1: Refactor L2CapPlugin to support socket pooling and EventChannel**

Update `L2CapPlugin.kt` to manage multiple sockets and stream data back.

```kotlin
package com.example.routerelay

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.IOException
import java.util.concurrent.ConcurrentHashMap

class L2CapPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private var methodChannel : MethodChannel? = null
    private var eventChannel : EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    
    private val socketPool = ConcurrentHashMap<String, BluetoothSocket>()
    private val pluginScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.routerelay/l2cap")
        methodChannel?.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "io.routerelay/l2cap_stream")
        eventChannel?.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.error("UNSUPPORTED_VERSION", "L2CAP CoC requires Android 10+", null)
            return
        }

        when (call.method) {
            "open" -> {
                val deviceId = call.argument<String>("deviceId")
                val psm = call.argument<Int>("psm") ?: 0
                if (deviceId != null) openChannel(deviceId, psm, result)
                else result.error("INVALID_ARGUMENT", "deviceId is null", null)
            }
            "send" -> {
                val deviceId = call.argument<String>("deviceId")
                val data = call.argument<ByteArray>("data")
                if (data != null) sendData(deviceId, data, result)
                else result.error("INVALID_ARGUMENT", "data is null", null)
            }
            "close" -> {
                val deviceId = call.argument<String>("deviceId")
                closeChannel(deviceId, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun openChannel(deviceId: String, psm: Int, result: Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter() ?: return result.error("BLUETOOTH_UNAVAILABLE", "No adapter", null)
        val device = adapter.getRemoteDevice(deviceId)
        
        pluginScope.launch {
            try {
                val socket = device.createL2capChannel(psm)
                socket.connect()
                socketPool[deviceId] = socket
                startReadLoop(deviceId, socket)
                withContext(Dispatchers.Main) { result.success(null) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) { result.error("CONNECTION_FAILED", e.message, null) }
            }
        }
    }

    private fun startReadLoop(deviceId: String, socket: BluetoothSocket) {
        pluginScope.launch {
            val inputStream = socket.inputStream
            val buffer = ByteArray(1024)
            try {
                while (isActive && socketPool.containsKey(deviceId)) {
                    val bytesRead = inputStream.read(buffer)
                    if (bytesRead > 0) {
                        val data = buffer.copyOfRange(0, bytesRead)
                        withContext(Dispatchers.Main) {
                            eventSink?.success(mapOf("deviceId" to deviceId, "data" to data))
                        }
                    }
                }
            } catch (e: IOException) {
                closeChannel(deviceId, null)
            }
        }
    }

    private fun sendData(deviceId: String?, data: ByteArray, result: Result) {
        pluginScope.launch {
            try {
                if (deviceId != null) {
                    socketPool[deviceId]?.outputStream?.write(data)
                } else {
                    socketPool.values.forEach { it.outputStream.write(data) }
                }
                withContext(Dispatchers.Main) { result.success(null) }
            } catch (e: IOException) {
                withContext(Dispatchers.Main) { result.error("SEND_FAILED", e.message, null) }
            }
        }
    }

    private fun closeChannel(deviceId: String?, result: Result?) {
        if (deviceId != null) {
            socketPool.remove(deviceId)?.close()
        } else {
            socketPool.values.forEach { it.close() }
            socketPool.clear()
        }
        result?.success(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        pluginScope.cancel()
        closeChannel(null, null)
    }
}
```

- [ ] **Step 2: Update BleService to handle multi-peer stream**

```dart
// lib/services/ble_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class BleService {
  static const MethodChannel _l2capChannel = MethodChannel('io.routerelay/l2cap');
  static const EventChannel _l2capStream = EventChannel('io.routerelay/l2cap_stream');

  final StreamController<Map<String, dynamic>> _incomingDataController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingData => _incomingDataController.stream;

  BleService() {
    _l2capStream.receiveBroadcastStream().listen((data) {
      _incomingDataController.add(Map<String, dynamic>.from(data));
    });
  }

  Future<void> send(Uint8List data, {String? deviceId}) async {
    await _l2capChannel.invokeMethod('send', {'data': data, 'deviceId': deviceId});
  }
  
  // ... rest of implementation
}
```

- [ ] **Step 3: Commit Native connectivity changes**

```bash
git add android/app/src/main/kotlin/com/example/routerelay/L2CapPlugin.kt lib/services/ble_service.dart
git commit -m "feat: implement multi-peer L2CAP socket pool and EventChannel"
```

---

### Task 2: Mesh Isolate Scaffolding

**Files:**
- Create: `lib/services/mesh_isolate.dart`
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Create MeshIsolate worker class**

```dart
// lib/services/mesh_isolate.dart
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import '../generated/protos/mesh.pb.dart';

class MeshIsolate {
  static void spawn(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is TransferableTypedData) {
        final rawData = message.materialize().asUint8List();
        // Processing logic will go here
      }
    });
  }
}
```

- [ ] **Step 2: Update MeshService to spawn and communicate with Isolate**

```dart
// lib/services/mesh_service.dart
class MeshService {
  SendPort? _isolateSendPort;
  
  Future<void> startIsolate() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(MeshIsolate.spawn, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
      } else {
        // Handle results from isolate
      }
    });
  }

  void _onRawDataReceived(Uint8List data) {
    _isolateSendPort?.send(TransferableTypedData.fromList([data]));
  }
}
```

- [ ] **Step 3: Commit Isolate scaffolding**

```bash
git add lib/services/mesh_isolate.dart lib/services/mesh_service.dart
git commit -m "feat: scaffold MeshIsolate with zero-copy TransferableTypedData"
```

---

### Task 3: Mesh Logic Migration & Priority Queue

**Files:**
- Modify: `lib/services/mesh_isolate.dart`
- Create: `lib/services/priority_queue.dart`

- [ ] **Step 1: Implement PriorityQueue**

```dart
// lib/services/priority_queue.dart
import 'dart:collection';
import '../generated/protos/mesh.pb.dart';

class MeshPriorityQueue {
  final _queues = <MeshPayload_Type, ListQueue<MeshPayload>>{
    MeshPayload_Type.SOS: ListQueue(),
    MeshPayload_Type.VOICE: ListQueue(),
    MeshPayload_Type.TELEMETRY: ListQueue(),
    MeshPayload_Type.TILE_REQUEST: ListQueue(),
  };

  void add(MeshPayload payload) {
    _queues[payload.type]?.add(payload);
  }

  MeshPayload? pop() {
    return _queues[MeshPayload_Type.SOS]?.removeFirst() ??
           _queues[MeshPayload_Type.VOICE]?.removeFirst() ??
           _queues[MeshPayload_Type.TELEMETRY]?.removeFirst() ??
           _queues[MeshPayload_Type.TILE_REQUEST]?.removeFirst();
  }
}
```

- [ ] **Step 2: Migrate deduplication and routing to MeshIsolate**

Update `MeshIsolate.spawn` to include `MeshPriorityQueue` and deduplication logic.

- [ ] **Step 3: Commit Mesh Logic Migration**

```bash
git add lib/services/priority_queue.dart lib/services/mesh_isolate.dart
git commit -m "feat: implement priority queue and migrate mesh logic to isolate"
```

---

### Task 4: Adaptive Voice Feedback Loop

**Files:**
- Modify: `lib/services/audio_service.dart`
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Add bitrate control to AudioService**

```dart
// lib/services/audio_service.dart
class AudioService {
  int _currentBitrate = 16000;
  
  void setBitrate(int bitrate) {
    _currentBitrate = bitrate;
    // Re-initialize encoder with new bitrate
    _encoder?.destroy();
    _encoder = SimpleOpusEncoder(
      sampleRate: sampleRate,
      channels: channels,
      application: Application.voip,
    );
  }
}
```

- [ ] **Step 2: Implement CongestionSignal from Isolate to UI**

MeshIsolate sends `CongestionSignal` when queue > Threshold. MeshService calls `AudioService.setBitrate`.

- [ ] **Step 3: Commit Adaptive Voice**

```bash
git add lib/services/audio_service.dart lib/services/mesh_service.dart
git commit -m "feat: implement adaptive voice quality based on mesh congestion"
```

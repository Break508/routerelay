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

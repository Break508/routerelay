package com.example.routerelay

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.io.OutputStream
import java.util.UUID

class L2CapPlugin: FlutterPlugin, MethodCallHandler {
    private var channel : MethodChannel? = null
    private var socket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.routerelay/l2cap")
        channel?.setMethodCallHandler(this)
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
                if (deviceId != null) {
                    openChannel(deviceId, psm, result)
                } else {
                    result.error("INVALID_ARGUMENT", "deviceId is null", null)
                }
            }
            "send" -> {
                val data = call.argument<ByteArray>("data")
                if (data != null) {
                    sendData(data, result)
                } else {
                    result.error("INVALID_ARGUMENT", "data is null", null)
                }
            }
            "close" -> {
                closeChannel(result)
            }
            else -> result.notImplemented()
        }
    }

    private fun openChannel(deviceId: String, psm: Int, result: Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }
        val device: BluetoothDevice = adapter.getRemoteDevice(deviceId)
        
        Thread {
            try {
                // Using createL2capChannel (BLE) which was added in API 29
                socket = device.createL2capChannel(psm)
                socket?.connect()
                outputStream = socket?.outputStream
                result.success(null)
            } catch (e: Exception) {
                result.error("CONNECTION_FAILED", e.message, null)
            }
        }.start()
    }

    private fun sendData(data: ByteArray, result: Result) {
        Thread {
            try {
                outputStream?.write(data)
                result.success(null)
            } catch (e: IOException) {
                result.error("SEND_FAILED", e.message, null)
            }
        }.start()
    }

    private fun closeChannel(result: Result) {
        try {
            outputStream?.close()
            socket?.close()
            socket = null
            outputStream = null
            result.success(null)
        } catch (e: IOException) {
            result.error("CLOSE_FAILED", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        socket?.close()
    }
}

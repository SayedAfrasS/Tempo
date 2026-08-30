package com.weekflow.weekflow

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "tempo/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler(object : MethodChannel.MethodCallHandler {
            override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
                if (call.method == "isIgnoringBatteryOptimizations") {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                } else if (call.method == "requestIgnoreBatteryOptimizations") {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                            result.success(true)
                        } catch (e2: Exception) {
                            result.success(false)
                        }
                    }
                } else if (call.method == "openExactAlarmSettings") {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // Android 12+
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        try {
                            // Fallback to app info page
                            startActivity(Intent("android.settings.APPLICATION_DETAILS_SETTINGS").apply {
                                data = Uri.parse("package:$packageName")
                            })
                            result.success(true)
                        } catch (e2: Exception) {
                            result.success(false)
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
        })
    }
}
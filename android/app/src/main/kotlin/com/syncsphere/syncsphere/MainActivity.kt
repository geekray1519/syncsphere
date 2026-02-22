package com.syncsphere.syncsphere

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "syncsphere/run_conditions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "isCharging" -> {
                    val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { filter ->
                        applicationContext.registerReceiver(null, filter)
                    }
                    val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
                    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL
                    result.success(isCharging)
                }

                "isBatterySaverEnabled" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(powerManager.isPowerSaveMode)
                }

                "getCurrentWifiSsid" -> {
                    try {
                        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                        @Suppress("DEPRECATION")
                        val wifiInfo = wifiManager.connectionInfo
                        val ssid = wifiInfo?.ssid
                        if (ssid != null && ssid != "<unknown ssid>" && ssid != "0x") {
                            result.success(ssid.replace("\"", ""))
                        } else {
                            result.success(null)
                        }
                    } catch (_: SecurityException) {
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}

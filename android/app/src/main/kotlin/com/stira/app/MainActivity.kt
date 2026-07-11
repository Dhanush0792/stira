package com.stira.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ComponentName
import android.content.pm.PackageManager

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

class MainActivity : FlutterFragmentActivity() {
    private val SHADOW_CHANNEL = "com.stira.app/shadow_mode"
    private val BATTERY_CHANNEL = "com.stira.app/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHADOW_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "applyDisguise") {
                val disguise = call.argument<String>("disguise") ?: "None"
                applyDisguise(disguise)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBatteryOptimizationIgnored" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimization" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(null)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun applyDisguise(disguise: String) {
        val targets = mapOf(
            "None" to "com.stira.app.MainActivityAlias_None",
            "Weather" to "com.stira.app.MainActivityAlias_Weather",
            "Calculator" to "com.stira.app.MainActivityAlias_Calculator",
            "Finance" to "com.stira.app.MainActivityAlias_Finance",
            "Notes" to "com.stira.app.MainActivityAlias_Notes"
        )
        val selectedTarget = targets[disguise] ?: targets["None"]!!

        val pm = packageManager
        
        // 1. Enable the target alias first
        pm.setComponentEnabledSetting(
            ComponentName(this, selectedTarget),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP // We'll kill it once at the end if needed
        )

        // 2. Disable all other aliases
        for (targetClass in targets.values) {
            if (targetClass != selectedTarget) {
                pm.setComponentEnabledSetting(
                    ComponentName(this, targetClass),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
        }
        
        // Note: Some launchers require an app restart or a specific flag to refresh the icon.
        // We omit DONT_KILL_APP in a final 'ping' or just let the system handle it.
        // On modern Android, disabling the launcher activity often kills the process anyway.
    }
}

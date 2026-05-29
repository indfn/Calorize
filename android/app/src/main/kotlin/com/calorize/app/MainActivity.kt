package com.calorize.app

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.calorize.app/widget"
    private val THEME_CHANNEL = "com.calorize.app/theme"
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val themeMode = sharedPrefs.getString("flutter.themeMode", "")
        if (themeMode == "ThemeMode.light" || themeMode == "light" || themeMode == "VGhlbWVNb2RlLmxpZ2h0") {
            setTheme(R.style.LaunchThemeLight)
        } else if (themeMode == "ThemeMode.dark" || themeMode == "dark" || themeMode == "VGhlbWVNb2RlLmRhcms=") {
            setTheme(R.style.LaunchThemeDark)
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            val uiManager = getSystemService(Context.UI_MODE_SERVICE) as android.app.UiModeManager
            if (themeMode == "ThemeMode.light" || themeMode == "light" || themeMode == "VGhlbWVNb2RlLmxpZ2h0") {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_NO)
            } else if (themeMode == "ThemeMode.dark" || themeMode == "dark" || themeMode == "VGhlbWVNb2RlLmRhcms=") {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_YES)
            } else {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_AUTO)
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent?.data?.toString()?.let { action ->
            methodChannel?.invokeMethod("onWidgetClick", action)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Clear stale scheduled notification cache that can cause Gson deserialization
        // failures after package rename (Missing type parameter error).
        getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE).edit().clear().apply()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, THEME_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setThemeMode") {
                val themeMode = call.argument<String>("themeMode")
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                    val uiManager = getSystemService(Context.UI_MODE_SERVICE) as android.app.UiModeManager
                    when (themeMode) {
                        "light" -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_NO)
                        "dark" -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_YES)
                        else -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_AUTO)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        methodChannel = null
        super.onDestroy()
    }
}

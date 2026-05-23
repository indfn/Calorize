package com.example.calorize

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

/**
 * Widget provider for home screen widgets.
 * Delegates to [DashboardWidgetProvider] and [ShortcutsWidgetProvider].
 */
abstract class CalorizeWidgetProvider : AppWidgetProvider()

class DashboardWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateDashboardWidget(context, appWidgetManager, appWidgetId)
        }
    }
}

class ShortcutsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateShortcutsWidget(context, appWidgetManager, appWidgetId)
        }
    }
}

// Helper functions
fun updateDashboardWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val views = RemoteViews(context.packageName, R.layout.widget_dashboard)

    val dataString = widgetData.getString("widget_data", "{}")
    val json = JSONObject(dataString)

    // Parse data with 0/clear defaults for clean state
    val caloriesLeft = json.optInt("caloriesLeft", 0)
    val caloriesConsumed = json.optInt("caloriesConsumed", 0)
    val caloriesGoal = json.optInt("caloriesGoal", 2000)
    val percentageText = json.optString("percentageText", "0%")
    val proteinLeft = json.optInt("proteinLeft", 0)
    val carbsLeft = json.optInt("carbsLeft", 0)
    val fatsLeft = json.optInt("fatsLeft", 0)
    val progress = json.optInt("progress", 0)

    // Update Views
    views.setTextViewText(R.id.tv_percentage, percentageText)
    views.setTextViewText(R.id.tv_consumed_goal, "$caloriesConsumed / $caloriesGoal")
    views.setTextViewText(R.id.tv_protein_value, "${proteinLeft}g")
    views.setTextViewText(R.id.tv_carbs_value, "${carbsLeft}g")
    views.setTextViewText(R.id.tv_fats_value, "${fatsLeft}g")
    views.setProgressBar(R.id.pb_calories, 100, progress, false)

    // Add tap-to-open
    setOnClickOpenApp(context, views, R.id.widget_root, "calorize://dashboard")

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

fun updateShortcutsWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val views = RemoteViews(context.packageName, R.layout.widget_shortcuts)

    // Click Listeners
    setOnClickOpenApp(context, views, R.id.btn_scan_food, "calorize://scan_ai")
    setOnClickOpenApp(context, views, R.id.btn_barcode, "calorize://scan_barcode")

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

fun setOnClickOpenApp(context: Context, views: RemoteViews, viewId: Int, uriString: String) {
    android.util.Log.d("WidgetClick", "Setting up click for URI: $uriString")
    
    // Create intent to launch MainActivity with URI as data
    val intent = Intent(context, MainActivity::class.java).apply {
        action = Intent.ACTION_VIEW
        data = Uri.parse(uriString)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }
    
    val pendingIntent = PendingIntent.getActivity(
        context,
        uriString.hashCode(),
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    
    views.setOnClickPendingIntent(viewId, pendingIntent)
}

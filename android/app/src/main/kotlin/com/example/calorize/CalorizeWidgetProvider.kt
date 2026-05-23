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

class CalorizeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Determine which layout to use based on the widget options or tag?
            // Actually, usually we register different providers for different widgets.
            // But the user asked for "CalorizeWidgetProvider.kt" (singular).
            // We can check the widget info or just try to update both if they share the provider,
            // but usually it's better to have separate providers or check the layout.
            // However, Android widgets are bound to a specific XML info which specifies the layout.
            // If we use one provider for two widgets, we need to know which one is being updated.
            // A common trick is to check the options, but simpler is to have one provider class
            // that handles both if they are just different layouts, OR separate classes.
            // The prompt asks for "Create CalorizeWidgetProvider.kt".
            // I will implement logic to handle both, or maybe the user implies one provider per widget?
            // "Generate the Native XML layouts and Kotlin logic for two distinct widgets."
            // "Create CalorizeWidgetProvider.kt." -> Singular.
            // I'll assume this provider handles both. I'll need to check which layout is associated.
            // Actually, `onUpdate` is called for all widgets of this provider.
            // If I register this provider for BOTH widgets in AndroidManifest, I need to know which one it is.
            // But usually, you have one Class per <receiver>.
            // So I should probably create `DashboardWidgetProvider` and `ShortcutsWidgetProvider` inheriting from `CalorizeWidgetProvider` or just put logic in one and register it twice?
            // No, if I register the SAME class for two different widget metadata, `onUpdate` doesn't tell me which "type" it is easily without checking options.
            // The cleanest way is to have two classes. But the user asked for `CalorizeWidgetProvider.kt`.
            // I will create `CalorizeWidgetProvider` as a base or shared logic, and maybe `DashboardProvider` and `ShortcutsProvider` inside it or as separate files?
            // Or I can just check `appWidgetManager.getAppWidgetOptions(appWidgetId)` to see the initial layout?
            // Let's try to make it simple: One provider, but maybe I can distinguish by some data?
            // Actually, if I use the SAME provider for both, I can't easily distinguish.
            // I will create TWO providers in the same file or separate files if needed.
            // But strictly following "Create CalorizeWidgetProvider.kt", I will put the logic there.
            // I'll define `DashboardWidgetProvider` and `ShortcutsWidgetProvider` as subclasses in the same file if possible, or just use one class and try to update both layouts?
            // No, `updateAppWidget` needs to pass the `RemoteViews` with the correct layout.
            // If I pass the wrong layout, it won't work.
            // I will split it into `DashboardWidgetProvider` and `ShortcutsWidgetProvider` inside `CalorizeWidgetProvider.kt` to be safe and clean.

            // Wait, if I use one class for both, I can't specify different `initialLayout` in `appwidget-provider` XML easily?
            // Yes I can, I have two XML files for metadata.
            // `widget_info_dashboard.xml` -> `android:name="com.example.calorize.CalorizeWidgetProvider"` (or Dashboard subclass)
            // `widget_info_shortcuts.xml` -> `android:name="com.example.calorize.CalorizeWidgetProvider"` (or Shortcuts subclass)
            // If they both point to the same class, `onUpdate` is called.
            // I can't distinguish easily.
            // I will create two classes in the file.
        }
    }
}

// Let's actually write the file with two classes.

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

    // Parse data with defaults for preview
    val caloriesLeft = json.optInt("caloriesLeft", 1737)
    val caloriesConsumed = json.optInt("caloriesConsumed", 500)
    val caloriesGoal = json.optInt("caloriesGoal", 2000)
    val percentageText = json.optString("percentageText", "25%")
    val proteinLeft = json.optInt("proteinLeft", 117)
    val carbsLeft = json.optInt("carbsLeft", 209)
    val fatsLeft = json.optInt("fatsLeft", 48)
    val progress = json.optInt("progress", 25)

    // Update Views
    views.setTextViewText(R.id.tv_percentage, percentageText)
    views.setTextViewText(R.id.tv_consumed_goal, "$caloriesConsumed / $caloriesGoal")
    views.setTextViewText(R.id.tv_protein_value, "${proteinLeft}g")
    views.setTextViewText(R.id.tv_carbs_value, "${carbsLeft}g")
    views.setTextViewText(R.id.tv_fats_value, "${fatsLeft}g")
    views.setProgressBar(R.id.pb_calories, 100, progress, false)

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

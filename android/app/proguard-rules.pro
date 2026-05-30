# Gson uses TypeToken with anonymous classes to capture generic type info.
# R8 strips the Signature attribute by default, causing "Missing type parameter."
-keepattributes Signature
-keepattributes *Annotation*

# Keep flutterlocalnotifications classes used by Gson serialization
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson TypeToken needs generic signature to read the type parameter
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keepclassmembers class * extends com.google.gson.reflect.TypeToken {
    public <init>();
}

# ===================================================
# CRITICAL: Keep all custom Calorize classes used by
# widgets, notifications, and method channels.
#
# These classes are referenced:
#   - via string name in AndroidManifest.xml (receivers & widget providers)
#   - via MethodChannel from Dart code
#
# R8 cannot see these code paths and would strip or rename
# them, causing ClassNotFoundException at runtime.
# ===================================================
-keep class com.calorize.app.DashboardWidgetProvider { *; }
-keep class com.calorize.app.ShortcutsWidgetProvider { *; }
-keep class com.calorize.app.MainActivity { *; }

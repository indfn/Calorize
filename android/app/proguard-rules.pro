# Gson uses TypeToken with anonymous classes to capture generic type info.
# R8 strips the Signature attribute by default, causing "Missing type parameter."
-keepattributes Signature
-keepattributes *Annotation*

# Keep flutterlocalnotifications classes used by Gson serialization
-keep class com.dexterous.flutterlocalnotifications.** { *; }

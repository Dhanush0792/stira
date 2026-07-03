# Proguard rules for Stira

# Hive
-keep class io.hive.** { *; }
-keepnames class io.hive.** { *; }
-keepattributes *Annotation*
-keep class * extends io.hive.TypeAdapter
-keep class * extends io.hive.HiveObject

# Firebase
-keep class com.google.firebase.** { *; }

# Flutter
-keep class io.flutter.** { *; }

# Workmanager
-keep class be.tramckrijte.workmanager.** { *; }
-keep class androidx.work.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature,EnclosingMethod,InnerClasses

# Prevent stripping of Kotlin background workers
-keep class * extends androidx.work.ListenableWorker { *; }

# Ignore warnings for missing Play Core classes referenced by Flutter Engine
-dontwarn com.google.android.play.core.**

# Keep WorkManager classes and callbacks - CRITICAL
-keep class androidx.work.** { *; }
-keep interface androidx.work.** { *; }
-dontwarn androidx.work.**
-keepclassmembers class androidx.work.** { *; }

# Keep the WorkManager callback dispatcher - CRITICAL
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(...);
}

# Keep all methods in classes that extend WorkManager classes
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(...);
    public void doWork(...);
}

# Keep workmanager callback dispatcher specifically
-keep class **.callbackDispatcher { *; }
-keepclasseswithmembers class * {
    public static void callbackDispatcher(...);
}

# Keep Flutter entry points for background execution
-keep @pragma class * { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Keep notification classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class * extends androidx.core.app.NotificationCompat$Style { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Dart VM entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }

# Keep Kotlin classes
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Keep SharedPreferences
-keep class androidx.preference.** { *; }

# Preserve annotated classes
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep all classes with @pragma annotation (Dart VM entry points) - CRITICAL
-keep class ** {
    @pragma <methods>;
}
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep all top-level functions (Dart VM entry points)
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Aggressive keep for Flutter background isolates
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.dart.DartExecutor { *; }

# Fix for R8 missing class warnings
-dontwarn javax.xml.stream.**
-dontwarn org.apache.tika.**
-dontwarn org.xmlpull.v1.**
-dontwarn javax.servlet.**
-dontwarn org.slf4j.**
-dontwarn org.apache.commons.**

# Keep HTTP classes
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# Keep Gson/JSON classes
-keepattributes Signature
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }


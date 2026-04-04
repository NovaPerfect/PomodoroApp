# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firestore
-keep class com.google.firestore.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Keep all model classes
-keep class com.novaperfect.nekodoro.** { *; }

# Prevent obfuscation of classes used with reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

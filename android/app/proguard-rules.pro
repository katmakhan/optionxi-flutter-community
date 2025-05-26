#########################################
# Flutter Default Rules (Required)
#########################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

#########################################
# Main Activity (Adjust to your package)
#########################################
-keep class com.optionxi.app.MainActivity { *; }

#########################################
# Firebase Core
#########################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

#########################################
# Firebase Auth
#########################################
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.internal.firebase-auth-api.** { *; }
-dontwarn com.google.android.gms.internal.firebase-auth-api.**

#########################################
# Firebase Firestore
#########################################
-keep class com.google.firebase.firestore.** { *; }

#########################################
# Firebase Analytics
#########################################
-keep class com.google.firebase.analytics.** { *; }

#########################################
# Google Sign-In + Play Services
#########################################
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.internal.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

#########################################
# Kotlin and Coroutines
#########################################
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.**

#########################################
# JSON / GSON
#########################################
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

#########################################
# Multidex Support
#########################################
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

#########################################
# Desugaring (Java 8+ features)
#########################################
-keep class j$.** { *; }

#########################################
# App-specific data models (if needed)
#########################################
-keep class com.optionxi.app.datamodels.** { *; }

#########################################
# Google Play (In-App Updates, etc.)
#########################################
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

#########################################
# Optional: Remove All Logs (release only)
#########################################
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

#########################################
# Misc - Suppress known safe warnings
#########################################
-dontwarn org.codehaus.mojo.animal_sniffer.**
-dontwarn javax.annotation.**

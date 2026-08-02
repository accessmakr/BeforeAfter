# ProGuard rules for BeforeAfter

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# In-App Purchase
-keep class io.flutter.plugins.inapppurchase.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

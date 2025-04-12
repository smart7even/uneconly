-keep interface retrofit2.** { *; }
-dontwarn retrofit2.**

-keep class retrofit2.** { *; }

-keep class com.google.gson.** { *; }
-keep class com.roadmapik.uneconly.** { *; }

-keepattributes Signature
-keepattributes RuntimeVisibleAnnotations
-keepattributes AnnotationDefault

-keepattributes InnerClasses
-keepattributes EnclosingMethod

-keep class **.model.** { *; }

-dontwarn java.lang.invoke.*

-keep class kotlin.Metadata { *; }
-keep class kotlin.jvm.internal.** { *; }
-dontwarn kotlin.**

-keep class com.builttoroam.devicecalendar.** { *; }
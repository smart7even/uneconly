package com.roadmapik.uneconly

import com.google.gson.annotations.SerializedName
import java.util.Date

data class Lesson(
        @SerializedName("name") val name: String,
        @SerializedName("start") val start: Date,
        @SerializedName("end") val end: Date,
        @SerializedName("professor") val professor: String?,
        @SerializedName("location") val location: String
)

// Note: Kotlin's kotlinx.serialization handles the naming convention translation (like day_of_week to dayOfWeek) automatically if you use @SerialName annotation.
// However, in this case, those fields are commented out in the Swift code, so they're not included here.

// The Date class from java.util is used as an equivalent to Swift's Date.
// However, for more complex date-time operations, you might want to use java.time classes (e.g., LocalDateTime) which require API level 26 or higher on Android.

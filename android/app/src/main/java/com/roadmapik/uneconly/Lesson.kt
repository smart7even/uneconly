package com.roadmapik.uneconly

import com.google.gson.annotations.SerializedName
import java.util.Date

data class Lesson(
    @SerializedName("name") val name: String,
    @SerializedName("start") val start: Date,
    @SerializedName("end") val end: Date,
    @SerializedName("professor") val professor: String?,
    @SerializedName("location") val location: String,
    @SerializedName("lesson_type") val lessonType: String?,
    @SerializedName("group") val group: String?,
) {
    val displayName: String
        get() {
            val type = lessonType?.trim().orEmpty()
            if (type.isEmpty()) return name
            val suffix = " ($type)"
            return if (name.endsWith(suffix, ignoreCase = true)) {
                name.dropLast(suffix.length)
            } else {
                name
            }
        }
}

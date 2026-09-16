package com.roadmapik.uneconly

import android.content.Context
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.annotations.SerializedName
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query
import java.lang.reflect.Type
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.TimeUnit

data class LessonResponse(
    @SerializedName("lessons") val lessons: List<Lesson>,
)

private const val WIDGET_CACHE_PREFERENCES = "uneconly_widget_schedule"
private const val WIDGET_CACHE_KEY_PREFIX = "lessons.v2."
private val MOSCOW_TIME_ZONE: TimeZone = TimeZone.getTimeZone("Europe/Moscow")

interface DataProvider {
    @GET("group/{groupId}/lessons/next")
    fun fetchData(
        @Path("groupId") groupId: Int,
        @Query("after_date") afterDate: String,
    ): retrofit2.Call<LessonResponse>
}

class ServerLessonDataProvider(baseUrl: String) {
    private val dataProvider: DataProvider

    init {
        val client = OkHttpClient.Builder()
            .connectTimeout(4, TimeUnit.SECONDS)
            .readTimeout(6, TimeUnit.SECONDS)
            .writeTimeout(4, TimeUnit.SECONDS)
            .callTimeout(8, TimeUnit.SECONDS)
            .build()
        val gson = GsonBuilder()
            .registerTypeAdapter(Date::class.java, WidgetDateDeserializer())
            .create()

        dataProvider = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
            .create(DataProvider::class.java)
    }

    /** Returns null for a transport/server error and an empty list for a valid empty response. */
    fun fetchData(groupId: Int, dayStart: Date): List<Lesson>? = try {
        val response = dataProvider.fetchData(
            groupId = groupId,
            afterDate = widgetDateTimeFormat().format(dayStart),
        ).execute()
        if (response.isSuccessful) {
            response.body()?.lessons?.sortedBy { it.start }
        } else {
            null
        }
    } catch (_: Exception) {
        null
    }
}

data class CachedWidgetLessons(
    val groupId: Int,
    val savedAtMillis: Long,
    val lessons: List<CachedWidgetLesson>,
) {
    fun toLessons(): List<Lesson> = lessons.map(CachedWidgetLesson::toLesson)
}

data class CachedWidgetLesson(
    val name: String,
    val startMillis: Long,
    val endMillis: Long,
    val professor: String?,
    val location: String,
    val lessonType: String?,
    val group: String?,
) {
    fun toLesson(): Lesson = Lesson(
        name = name,
        start = Date(startMillis),
        end = Date(endMillis),
        professor = professor,
        location = location,
        lessonType = lessonType,
        group = group,
    )

    companion object {
        fun fromLesson(lesson: Lesson): CachedWidgetLesson = CachedWidgetLesson(
            name = lesson.name,
            startMillis = lesson.start.time,
            endMillis = lesson.end.time,
            professor = lesson.professor,
            location = lesson.location,
            lessonType = lesson.lessonType,
            group = lesson.group,
        )
    }
}

class WidgetLessonCache(context: Context) {
    private val preferences = context.getSharedPreferences(
        WIDGET_CACHE_PREFERENCES,
        Context.MODE_PRIVATE,
    )
    private val gson = Gson()

    fun read(groupId: Int): CachedWidgetLessons? {
        val value = preferences.getString(key(groupId), null) ?: return null
        return try {
            gson.fromJson(value, CachedWidgetLessons::class.java)
                ?.takeIf { it.groupId == groupId }
        } catch (_: Exception) {
            null
        }
    }

    fun write(groupId: Int, lessons: List<Lesson>, savedAt: Date) {
        val record = CachedWidgetLessons(
            groupId = groupId,
            savedAtMillis = savedAt.time,
            lessons = lessons.map(CachedWidgetLesson::fromLesson),
        )
        preferences.edit().putString(key(groupId), gson.toJson(record)).apply()
    }

    private fun key(groupId: Int): String = "$WIDGET_CACHE_KEY_PREFIX$groupId"
}

private class WidgetDateDeserializer : JsonDeserializer<Date> {
    override fun deserialize(
        json: JsonElement,
        typeOfT: Type,
        context: JsonDeserializationContext,
    ): Date {
        val value = json.asString
        val patterns = listOf(
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd",
        )
        for (pattern in patterns) {
            try {
                return SimpleDateFormat(pattern, Locale.US).apply {
                    isLenient = false
                    timeZone = MOSCOW_TIME_ZONE
                }.parse(value) ?: continue
            } catch (_: ParseException) {
                // Try the next supported server representation.
            }
        }
        throw ParseException("Unsupported lesson date", 0)
    }
}

fun widgetDateTimeFormat(): SimpleDateFormat =
    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).apply {
        timeZone = MOSCOW_TIME_ZONE
    }

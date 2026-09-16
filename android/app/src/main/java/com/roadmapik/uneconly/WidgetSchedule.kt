package com.roadmapik.uneconly

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.ceil

private val WIDGET_TIME_ZONE: TimeZone = TimeZone.getTimeZone("Europe/Moscow")
private val WIDGET_LOCALE = Locale.forLanguageTag("ru-RU")

data class WidgetSchedule(
    val now: Date,
    val lessons: List<Lesson>,
) {
    val normalizedLessons: List<Lesson> = normalizeWidgetLessons(lessons)

    val primaryLesson: Lesson?
        get() = normalizedLessons.firstOrNull { it.start <= now && now < it.end }
            ?: normalizedLessons.firstOrNull { it.start > now }

    val todayLessons: List<Lesson>
        get() = lessonsOn(now)

    val remainingTodayLessons: List<Lesson>
        get() = todayLessons.filter { it.end > now }

    val tomorrow: Date
        get() = Calendar.getInstance(WIDGET_TIME_ZONE).run {
            time = now
            add(Calendar.DAY_OF_YEAR, 1)
            time
        }

    val tomorrowLessons: List<Lesson>
        get() = lessonsOn(tomorrow)

    fun lessonsOn(date: Date): List<Lesson> = normalizedLessons.filter {
        isSameWidgetDay(it.start, date)
    }
}

private data class LessonSlot(
    val start: Long,
    val end: Long,
    val name: String,
    val lessonType: String,
)

fun normalizeWidgetLessons(lessons: List<Lesson>): List<Lesson> = lessons
    .groupBy {
        LessonSlot(
            start = it.start.time,
            end = it.end.time,
            name = it.displayName.lowercase(WIDGET_LOCALE),
            lessonType = it.lessonType.orEmpty().lowercase(WIDGET_LOCALE),
        )
    }
    .values
    .mapNotNull { alternatives ->
        val first = alternatives.firstOrNull() ?: return@mapNotNull null
        if (alternatives.size == 1) {
            first
        } else {
            first.copy(
                name = first.displayName,
                professor = null,
                location = "${alternatives.size} вариантов подгрупп",
            )
        }
    }
    .sortedWith(compareBy<Lesson> { it.start }.thenBy { it.displayName })

fun widgetTime(date: Date): String = widgetFormat("HH:mm", date)

fun widgetShortDate(date: Date): String =
    widgetFormat("EEE · d MMM", date).uppercase(WIDGET_LOCALE)

fun widgetCompactDate(date: Date): String = widgetFormat("dd.MM", date)

fun widgetCalendarDate(date: Date): String =
    widgetFormat("d MMMM", date).uppercase(WIDGET_LOCALE)

fun widgetStatus(lesson: Lesson, now: Date): String {
    if (lesson.start <= now && now < lesson.end) return "ИДЁТ"
    if (!isSameWidgetDay(lesson.start, now)) return "ДАЛЬШЕ"
    val minutes = maxOf(1, ceil((lesson.start.time - now.time) / 60_000.0).toInt())
    if (minutes < 60) return "$minutes МИН"
    val hours = minutes / 60
    return "$hours Ч"
}

fun widgetLessonCount(count: Int): String = "$count ${widgetLessonWord(count)}"

fun widgetLessonWord(count: Int): String {
    val mod100 = count % 100
    val mod10 = count % 10
    if (mod100 in 11..14) return "ПАР"
    return when (mod10) {
        1 -> "ПАРА"
        2, 3, 4 -> "ПАРЫ"
        else -> "ПАР"
    }
}

fun widgetLessonType(value: String?): String = when (value?.trim()?.lowercase(WIDGET_LOCALE)) {
    "лекция" -> "ЛЕК"
    "практика", "практическое занятие" -> "ПР"
    "лабораторная", "лабораторная работа" -> "ЛАБ"
    "семинар" -> "СЕМ"
    "экзамен" -> "ЭКЗ"
    "зачет", "зачёт" -> "ЗАЧ"
    "дифференцированный зачет", "дифференцированный зачёт" -> "ДИФЗАЧ"
    "пересдача" -> "ПЕРЕСД"
    null, "" -> ""
    else -> value.trim().uppercase(WIDGET_LOCALE)
}

fun widgetRoom(value: String): String {
    if (value.contains("вариант", ignoreCase = true)) return value
    val normalized = value
        .replace("аудитория", "ауд.", ignoreCase = true)
        .replace(Regex("\\s+"), " ")
        .trim()
    val roomMatch = Regex("^([^,]+?\\s*(?:ауд\\.?|каб\\.?))(?=\\s|$)", RegexOption.IGNORE_CASE)
        .find(normalized)
        ?.value
    return roomMatch ?: normalized.substringBefore(',').take(28)
}

fun widgetMetadata(lesson: Lesson): String = listOf(
    widgetLessonType(lesson.lessonType),
    widgetRoom(lesson.location),
).filter { it.isNotBlank() }.joinToString(" · ")

fun isCurrentWidgetLesson(lesson: Lesson, now: Date): Boolean =
    lesson.start <= now && now < lesson.end

fun widgetDayStart(date: Date): Date = Calendar.getInstance(WIDGET_TIME_ZONE).run {
    time = date
    set(Calendar.HOUR_OF_DAY, 0)
    set(Calendar.MINUTE, 0)
    set(Calendar.SECOND, 0)
    set(Calendar.MILLISECOND, 0)
    time
}

private fun isSameWidgetDay(first: Date, second: Date): Boolean {
    val firstCalendar = Calendar.getInstance(WIDGET_TIME_ZONE).apply { time = first }
    val secondCalendar = Calendar.getInstance(WIDGET_TIME_ZONE).apply { time = second }
    return firstCalendar.get(Calendar.ERA) == secondCalendar.get(Calendar.ERA) &&
        firstCalendar.get(Calendar.YEAR) == secondCalendar.get(Calendar.YEAR) &&
        firstCalendar.get(Calendar.DAY_OF_YEAR) == secondCalendar.get(Calendar.DAY_OF_YEAR)
}

private fun widgetFormat(pattern: String, date: Date): String =
    SimpleDateFormat(pattern, WIDGET_LOCALE).apply {
        timeZone = WIDGET_TIME_ZONE
    }.format(date)

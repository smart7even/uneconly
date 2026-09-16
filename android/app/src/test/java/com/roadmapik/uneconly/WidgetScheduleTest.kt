package com.roadmapik.uneconly

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class WidgetScheduleTest {
    @Test
    fun `subgroup alternatives collapse into one informative lesson`() {
        val lessons = (1..8).map { index ->
            lesson(
                name = "Профессиональный иностранный язык (Практика)",
                start = date("2026-09-16T14:35:00"),
                end = date("2026-09-16T16:05:00"),
                location = "$index ауд.",
                lessonType = "Практика",
            )
        }

        val normalized = normalizeWidgetLessons(lessons)

        assertEquals(1, normalized.size)
        assertEquals("Профессиональный иностранный язык", normalized.single().displayName)
        assertEquals("8 вариантов подгрупп", normalized.single().location)
    }

    @Test
    fun `compact widget advances to next day after todays lessons end`() {
        val schedule = WidgetSchedule(
            now = date("2026-09-16T20:00:00"),
            lessons = listOf(
                lesson(
                    name = "Право",
                    start = date("2026-09-16T10:45:00"),
                    end = date("2026-09-16T12:15:00"),
                ),
                lesson(
                    name = "Микроэкономика",
                    start = date("2026-09-17T10:45:00"),
                    end = date("2026-09-17T12:15:00"),
                ),
            ),
        )

        assertEquals("Микроэкономика", schedule.primaryLesson?.displayName)
        assertEquals("ДАЛЬШЕ", widgetStatus(schedule.primaryLesson!!, schedule.now))
    }

    @Test
    fun `large widget separates remaining today from tomorrow`() {
        val current = lesson(
            name = "Менеджмент",
            start = date("2026-09-16T12:50:00"),
            end = date("2026-09-16T14:20:00"),
        )
        val past = lesson(
            name = "Экономика фирмы",
            start = date("2026-09-16T10:45:00"),
            end = date("2026-09-16T12:15:00"),
        )
        val tomorrow = lesson(
            name = "Статистика",
            start = date("2026-09-17T09:00:00"),
            end = date("2026-09-17T10:30:00"),
        )
        val schedule = WidgetSchedule(
            now = date("2026-09-16T13:15:00"),
            lessons = listOf(past, current, tomorrow),
        )

        assertEquals(listOf("Менеджмент"), schedule.remainingTodayLessons.map { it.displayName })
        assertEquals(listOf("Статистика"), schedule.tomorrowLessons.map { it.displayName })
        assertTrue(isCurrentWidgetLesson(current, schedule.now))
        assertFalse(isCurrentWidgetLesson(past, schedule.now))
    }

    @Test
    fun `lesson metadata uses compact type and room`() {
        val lesson = lesson(
            name = "Линейная алгебра (Практика)",
            start = date("2026-09-16T10:45:00"),
            end = date("2026-09-16T12:15:00"),
            location = "3117 ауд. Грибоедова 30/32",
            lessonType = "Практика",
        )

        assertEquals("Линейная алгебра", lesson.displayName)
        assertEquals("ПР · 3117 ауд.", widgetMetadata(lesson))
    }

    @Test
    fun `russian lesson pluralization handles teen exceptions`() {
        assertEquals("ПАРА", widgetLessonWord(1))
        assertEquals("ПАРЫ", widgetLessonWord(4))
        assertEquals("ПАР", widgetLessonWord(11))
        assertEquals("ПАР", widgetLessonWord(14))
        assertEquals("ПАРА", widgetLessonWord(21))
    }

    @Test
    fun `compact status does not wrap long hour countdowns with minutes`() {
        val next = lesson(
            name = "Право",
            start = date("2026-09-16T09:00:00"),
            end = date("2026-09-16T10:30:00"),
        )

        assertEquals("7 Ч", widgetStatus(next, date("2026-09-16T01:41:00")))
    }

    private fun lesson(
        name: String,
        start: Date,
        end: Date,
        location: String = "3117 ауд.",
        lessonType: String? = "Лекция",
    ): Lesson = Lesson(
        name = name,
        start = start,
        end = end,
        professor = "Преподаватель",
        location = location,
        lessonType = lessonType,
        group = null,
    )

    private fun date(value: String): Date = SimpleDateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
        Locale.US,
    ).apply {
        timeZone = TimeZone.getTimeZone("Europe/Moscow")
    }.parse(value)!!
}

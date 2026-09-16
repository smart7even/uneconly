package com.roadmapik.uneconly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Date
import java.util.concurrent.Executors

private const val WIDGET_REFRESH_ACTION = "com.roadmapik.uneconly.action.REFRESH_WIDGET"
private const val WIDGET_BASE_URL = "https://roadmapik.com:5000/"
private const val MEDIUM_WIDTH_DP = 250
private const val LARGE_HEIGHT_DP = 260

private enum class WidgetDataState {
    LOADED,
    CACHED,
    OFFLINE,
}

private data class WidgetRenderData(
    val schedule: WidgetSchedule,
    val groupName: String?,
    val updatedAt: Date,
    val state: WidgetDataState,
)

class UWidget : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        if (
            intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == WIDGET_REFRESH_ACTION
        ) {
            val manager = AppWidgetManager.getInstance(context)
            val requestedIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
            val singleId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID,
            )
            val appWidgetIds: IntArray = requestedIds?.takeIf { it.isNotEmpty() }
                ?: if (singleId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                    intArrayOf(singleId)
                } else {
                    manager.getAppWidgetIds(ComponentName(context, UWidget::class.java))
                }
            if (appWidgetIds.isEmpty()) return

            val pendingResult = goAsync()
            EXECUTOR.execute {
                try {
                    refreshWidgets(context.applicationContext, manager, appWidgetIds)
                } finally {
                    pendingResult.finish()
                }
            }
            return
        }
        super.onReceive(context, intent)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        renderSavedState(context, appWidgetManager, intArrayOf(appWidgetId))
        context.sendBroadcast(
            Intent(context, UWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            },
        )
    }

    companion object {
        private val EXECUTOR = Executors.newCachedThreadPool()
    }
}

private fun refreshWidgets(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val groupId = widgetData.getInt("groupId", 0)
    val groupName = widgetData.getString("groupName", null)
    if (groupId <= 0) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, messageViews(context, id, configured = false))
        }
        return
    }

    val cache = WidgetLessonCache(context)
    val cached = cache.read(groupId)
    if (cached != null) {
        updateWidgets(
            context = context,
            appWidgetManager = appWidgetManager,
            appWidgetIds = appWidgetIds,
            data = WidgetRenderData(
                schedule = WidgetSchedule(Date(), cached.toLessons()),
                groupName = groupName,
                updatedAt = Date(cached.savedAtMillis),
                state = WidgetDataState.CACHED,
            ),
        )
    }

    val now = Date()
    val lessons = ServerLessonDataProvider(WIDGET_BASE_URL).fetchData(
        groupId = groupId,
        dayStart = widgetDayStart(now),
    )
    if (lessons == null) {
        if (cached != null) {
            updateWidgets(
                context = context,
                appWidgetManager = appWidgetManager,
                appWidgetIds = appWidgetIds,
                data = WidgetRenderData(
                    schedule = WidgetSchedule(Date(), cached.toLessons()),
                    groupName = groupName,
                    updatedAt = Date(cached.savedAtMillis),
                    state = WidgetDataState.OFFLINE,
                ),
            )
        } else {
            appWidgetIds.forEach { id ->
                appWidgetManager.updateAppWidget(id, messageViews(context, id, configured = true))
            }
        }
        return
    }

    cache.write(groupId, lessons, now)
    val latestGroupId = HomeWidgetPlugin.getData(context).getInt("groupId", 0)
    if (latestGroupId != groupId) return
    updateWidgets(
        context = context,
        appWidgetManager = appWidgetManager,
        appWidgetIds = appWidgetIds,
        data = WidgetRenderData(
            schedule = WidgetSchedule(now, lessons),
            groupName = groupName,
            updatedAt = now,
            state = WidgetDataState.LOADED,
        ),
    )
}

private fun renderSavedState(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val groupId = widgetData.getInt("groupId", 0)
    val groupName = widgetData.getString("groupName", null)
    val cached = if (groupId > 0) WidgetLessonCache(context).read(groupId) else null
    if (cached == null) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(
                id,
                messageViews(context, id, configured = groupId > 0),
            )
        }
        return
    }
    updateWidgets(
        context = context,
        appWidgetManager = appWidgetManager,
        appWidgetIds = appWidgetIds,
        data = WidgetRenderData(
            schedule = WidgetSchedule(Date(), cached.toLessons()),
            groupName = groupName,
            updatedAt = Date(cached.savedAtMillis),
            state = WidgetDataState.CACHED,
        ),
    )
}

private fun updateWidgets(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    data: WidgetRenderData,
) {
    appWidgetIds.forEach { appWidgetId ->
        appWidgetManager.updateAppWidget(
            appWidgetId,
            responsiveViews(context, appWidgetManager, appWidgetId, data),
        )
    }
}

private fun responsiveViews(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
    data: WidgetRenderData,
): RemoteViews {
    val small = smallViews(context, appWidgetId, data)
    val medium = mediumViews(context, appWidgetId, data)
    val large = largeViews(context, appWidgetId, data)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        return RemoteViews(
            mapOf(
                SizeF(110f, 110f) to small,
                SizeF(MEDIUM_WIDTH_DP.toFloat(), 110f) to medium,
                SizeF(MEDIUM_WIDTH_DP.toFloat(), LARGE_HEIGHT_DP.toFloat()) to large,
            ),
        )
    }

    val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
    val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
    val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
    return when {
        width >= MEDIUM_WIDTH_DP && height >= LARGE_HEIGHT_DP -> large
        width >= MEDIUM_WIDTH_DP -> medium
        else -> small
    }
}

private fun smallViews(
    context: Context,
    appWidgetId: Int,
    data: WidgetRenderData,
): RemoteViews {
    val views = RemoteViews(context.packageName, R.layout.u_widget_small)
    bindActions(context, views, appWidgetId)
    val schedule = data.schedule
    val primary = schedule.primaryLesson
    val displayDate = primary?.start ?: schedule.now
    val displayLessons = schedule.lessonsOn(displayDate)
    views.setTextViewText(R.id.widget_date, widgetCompactDate(displayDate))
    views.setTextViewText(R.id.widget_count, widgetLessonCount(displayLessons.size))

    if (primary == null) {
        views.setTextViewText(R.id.widget_primary_time, "—")
        views.setTextViewText(R.id.widget_primary_status, "РАСПИСАНИЕ")
        views.setTextViewText(R.id.widget_primary_name, "Пар нет")
        views.setTextViewText(R.id.widget_primary_meta, "Ближайших занятий пока нет")
        views.setViewVisibility(R.id.widget_next_container, View.GONE)
        return views
    }

    val current = isCurrentWidgetLesson(primary, schedule.now)
    val accent = widgetColor(context, R.color.widget_accent)
    val ink = widgetColor(context, R.color.widget_ink)
    views.setTextViewText(R.id.widget_primary_time, widgetTime(primary.start))
    views.setTextViewText(R.id.widget_primary_status, widgetStatus(primary, schedule.now))
    views.setTextViewText(R.id.widget_primary_name, primary.displayName)
    views.setTextViewText(R.id.widget_primary_meta, widgetMetadata(primary))
    views.setTextColor(R.id.widget_primary_time, if (current) accent else ink)
    views.setTextColor(R.id.widget_primary_status, if (current) accent else widgetColor(context, R.color.widget_muted))

    val following = schedule.normalizedLessons.firstOrNull { it.start > primary.start }
    views.setViewVisibility(
        R.id.widget_next_container,
        if (following == null) View.GONE else View.VISIBLE,
    )
    if (following != null) {
        views.setTextViewText(R.id.widget_next_time, widgetTime(following.start))
        views.setTextViewText(R.id.widget_next_name, following.displayName)
        views.setTextViewText(R.id.widget_next_meta, widgetMetadata(following))
    }
    return views
}

private fun mediumViews(
    context: Context,
    appWidgetId: Int,
    data: WidgetRenderData,
): RemoteViews {
    val views = RemoteViews(context.packageName, R.layout.u_widget_medium)
    bindActions(context, views, appWidgetId)
    val schedule = data.schedule
    val lessons = schedule.todayLessons
    views.setTextViewText(R.id.widget_date, widgetShortDate(schedule.now))
    views.setTextViewText(R.id.widget_group, data.groupName?.uppercase() ?: "UNECONLY")
    views.setTextViewText(
        R.id.widget_count,
        if (lessons.isEmpty()) widgetLessonCount(0) else {
            "${widgetLessonCount(lessons.size)} · ДО ${widgetTime(lessons.last().end)}"
        },
    )
    views.removeAllViews(R.id.widget_rows)
    views.setViewVisibility(R.id.widget_empty_container, if (lessons.isEmpty()) View.VISIBLE else View.GONE)
    if (lessons.isEmpty()) {
        val next = schedule.normalizedLessons.firstOrNull { it.start > schedule.now }
        views.setTextViewText(R.id.widget_empty_title, "Пар нет")
        views.setTextViewText(
            R.id.widget_empty_detail,
            next?.let { "Ближайшая: ${widgetCalendarDate(it.start)}, ${widgetTime(it.start)} · ${it.displayName}" }
                ?: "Ближайших занятий пока нет",
        )
    } else {
        val visibleLimit = if (lessons.size > 4) 3 else 4
        addLessonRows(context, views, R.id.widget_rows, lessons.take(visibleLimit), schedule.now)
        bindOverflow(views, lessons.size - visibleLimit, lessons.lastOrNull()?.end)
    }
    bindFooter(views, data)
    return views
}

private fun largeViews(
    context: Context,
    appWidgetId: Int,
    data: WidgetRenderData,
): RemoteViews {
    val views = RemoteViews(context.packageName, R.layout.u_widget_large)
    bindActions(context, views, appWidgetId)
    val schedule = data.schedule
    val remainingToday = schedule.remainingTodayLessons
    val tomorrow = schedule.tomorrowLessons
    views.setTextViewText(R.id.widget_date, widgetShortDate(schedule.now))
    views.setTextViewText(R.id.widget_group, data.groupName?.uppercase() ?: "UNECONLY")
    views.setTextViewText(
        R.id.widget_today_status,
        when {
            remainingToday.isNotEmpty() -> "ОСТАЛОСЬ ${remainingToday.size}"
            schedule.todayLessons.isNotEmpty() -> "ПАРЫ ЗАКОНЧИЛИСЬ"
            else -> "СВОБОДНЫЙ ДЕНЬ"
        },
    )
    views.removeAllViews(R.id.widget_today_rows)
    addLessonRows(context, views, R.id.widget_today_rows, remainingToday.take(4), schedule.now)
    views.setViewVisibility(
        R.id.widget_today_empty,
        if (remainingToday.isEmpty()) View.VISIBLE else View.GONE,
    )

    views.setTextViewText(
        R.id.widget_tomorrow_title,
        "ЗАВТРА · ${widgetCalendarDate(schedule.tomorrow)}",
    )
    views.removeAllViews(R.id.widget_tomorrow_rows)
    val tomorrowLimit = if (remainingToday.isEmpty()) 5 else 3
    addLessonRows(context, views, R.id.widget_tomorrow_rows, tomorrow.take(tomorrowLimit), schedule.now)
    views.setViewVisibility(
        R.id.widget_tomorrow_empty,
        if (tomorrow.isEmpty()) View.VISIBLE else View.GONE,
    )
    val hiddenTomorrow = tomorrow.size - tomorrowLimit
    views.setViewVisibility(
        R.id.widget_tomorrow_overflow,
        if (hiddenTomorrow > 0) View.VISIBLE else View.GONE,
    )
    if (hiddenTomorrow > 0) {
        views.setTextViewText(
            R.id.widget_tomorrow_overflow,
            "ЕЩЁ ${widgetLessonCount(hiddenTomorrow)}",
        )
    }
    bindFooter(views, data)
    return views
}

private fun addLessonRows(
    context: Context,
    parent: RemoteViews,
    containerId: Int,
    lessons: List<Lesson>,
    now: Date,
) {
    lessons.forEach { lesson ->
        val row = RemoteViews(context.packageName, R.layout.u_widget_lesson_row)
        val current = isCurrentWidgetLesson(lesson, now)
        row.setTextViewText(R.id.widget_row_time, widgetTime(lesson.start))
        row.setTextViewText(R.id.widget_row_name, lesson.displayName)
        row.setTextViewText(
            R.id.widget_row_meta,
            listOf(if (current) "ИДЁТ" else "", widgetMetadata(lesson))
                .filter { it.isNotBlank() }
                .joinToString(" · "),
        )
        if (current) {
            row.setTextColor(R.id.widget_row_time, widgetColor(context, R.color.widget_accent))
            row.setTextColor(R.id.widget_row_meta, widgetColor(context, R.color.widget_accent))
        }
        parent.addView(containerId, row)
    }
}

private fun bindOverflow(views: RemoteViews, hiddenCount: Int, lastEnd: Date?) {
    views.setViewVisibility(
        R.id.widget_overflow,
        if (hiddenCount > 0) View.VISIBLE else View.GONE,
    )
    if (hiddenCount > 0) {
        views.setTextViewText(
            R.id.widget_overflow,
            buildString {
                append("ЕЩЁ ")
                append(widgetLessonCount(hiddenCount))
                if (lastEnd != null) append(" · ДО ${widgetTime(lastEnd)}")
            },
        )
    }
}

private fun bindFooter(views: RemoteViews, data: WidgetRenderData) {
    val label = when (data.state) {
        WidgetDataState.LOADED -> "ОБНОВЛЕНО"
        WidgetDataState.CACHED -> "СОХРАНЕНО"
        WidgetDataState.OFFLINE -> "ОФЛАЙН"
    }
    views.setTextViewText(R.id.widget_updated, "$label · ${widgetTime(data.updatedAt)}")
}

private fun messageViews(
    context: Context,
    appWidgetId: Int,
    configured: Boolean,
): RemoteViews {
    val views = RemoteViews(context.packageName, R.layout.u_widget_message)
    bindActions(context, views, appWidgetId)
    views.setTextViewText(
        R.id.widget_message_symbol,
        if (configured) "!" else "?",
    )
    views.setTextViewText(
        R.id.widget_message_title,
        if (configured) "Нет данных" else "Выберите группу",
    )
    views.setTextViewText(
        R.id.widget_message_detail,
        if (configured) {
            "Проверьте сеть и нажмите ↻"
        } else {
            "Откройте Uneconly и укажите свою группу"
        },
    )
    return views
}

private fun bindActions(context: Context, views: RemoteViews, appWidgetId: Int) {
    val launchIntent = HomeWidgetLaunchIntent.getActivity(
        context,
        MainActivity::class.java,
        Uri.parse("https://roadmapik.com/?homeWidget=schedule"),
    )
    views.setOnClickPendingIntent(R.id.widget_root, launchIntent)

    val refreshIntent = Intent(context, UWidget::class.java).apply {
        action = WIDGET_REFRESH_ACTION
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    }
    val flags = PendingIntent.FLAG_UPDATE_CURRENT or
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    views.setOnClickPendingIntent(
        R.id.widget_refresh,
        PendingIntent.getBroadcast(context, appWidgetId, refreshIntent, flags),
    )
}

@Suppress("DEPRECATION")
private fun widgetColor(context: Context, colorId: Int): Int =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        context.getColor(colorId)
    } else {
        context.resources.getColor(colorId)
    }

package com.roadmapik.uneconly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


/**
 * Implementation of App Widget functionality.
 */
class UWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val groupId = widgetData.getInt("groupId", 0)

    Log.i("UWidget", "groupId $groupId")

    if (groupId == 0) {
        val views = RemoteViews(context.packageName, R.layout.u_widget)
        views.setTextViewText(R.id.lesson_name, "Не выбрана группа")
        views.setTextViewText(R.id.lesson_location, "Укажите свою группу в приложении")

        appWidgetManager.updateAppWidget(appWidgetId, views)

        return
    }

    val serverDataProvider = ServerLessonDataProvider("https://roadmapik.com:5000/")
    serverDataProvider.fetchData(groupId = groupId) { lesson ->
        val views = RemoteViews(context.packageName, R.layout.u_widget)

        if (lesson == null) {
            Handler(Looper.getMainLooper()).post {
                views.setTextViewText(R.id.lesson_name, "Ошибка")
                views.setTextViewText(R.id.lesson_location, "Не удалось получить информацию с сервера")

                appWidgetManager.updateAppWidget(appWidgetId, views)
            }


            return@fetchData
        }

        Log.i("UWidget", lesson.toString())

        Handler(Looper.getMainLooper()).post {
            views.setTextViewText(R.id.lesson_name, lesson.name)
            views.setTextViewText(R.id.lesson_location, lesson.location)
            views.setTextViewText(R.id.lesson_time, formatDate(lesson.start))

            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.layout, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        return@fetchData
    }
}

fun formatDate(date: Date): String {
    val formatter = SimpleDateFormat("dd.MM.yyyy HH:mm", Locale.US)
    return formatter.format(date)
}
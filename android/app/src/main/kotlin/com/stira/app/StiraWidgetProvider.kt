package com.stira.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StiraWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // Read from SharedPreferences populated by home_widget
            val mantra = widgetData.getString("stira_mantra", "The baseline is steady.")
            views.setTextViewText(R.id.widget_mantra, mantra)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

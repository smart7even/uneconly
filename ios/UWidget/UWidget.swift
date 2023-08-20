//
//  UWidget.swift
//  UWidget
//
//  Created by Oleg on 20.08.2023.
//

import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let date = Date()
        return SimpleEntry(date: date, lesson: Lesson(
            name: "Тестовый предмет", start: date, end: date, professor: "Professor", location: "Main building"), isResponseFromServer: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        let entry = SimpleEntry(date: date, lesson: Lesson(
            name: "Тестовый предмет", start: date, end: date, professor: "Professor", location: "Main building"), isResponseFromServer: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.roadmapik.test")
        
        guard let groupId = userDefaults?.integer(forKey: "groupId") else {
            let entry = SimpleEntry(date: Date(), lesson: nil, isResponseFromServer: false)
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
            return
        }
        
        if (groupId == 0) {
            let entry = SimpleEntry(date: Date(), lesson: nil, isResponseFromServer: false)
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
            return
        }
        
        print("groupId \(groupId)")
        
        let dataProvider: DataProvider = ServerDataProvider(baseURL: "https://roadmapik.com:5000")
        dataProvider.fetchData(groupId: groupId) { lesson in
                    let entry = SimpleEntry(date: Date(), lesson: lesson, isResponseFromServer: true)
                    let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                    completion(timeline)
                }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let lesson: Lesson?
    let isResponseFromServer: Bool
}


struct UWidgetEntryView : View {
    var entry: Provider.Entry

    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
                    if let lesson = entry.lesson {
                        Text("\(lesson.name)").lineLimit(2)
//                        if let professor = lesson.professor {
//                            Text(professor)
//                        }
                        Text(lesson.location)
                        Text("\(formatTime(date: lesson.start))")
                    } else if (entry.isResponseFromServer) {
                        Text("Нет расписания следующих пар")
                    } else {
                        Text("Нет данных. Проверьте, что выбрали группу")
                    }
                }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // VStack takes all available space
        .padding(4)  // Padding inside the border
//        .overlay(
//            ContainerRelativeShape()
//                .stroke(Color.green, lineWidth: 10)
//                )
        .background(Color.clear)  // This ensures the VStack background is transparent and only the border is visible
    }
}

struct UWidget: Widget {
    let kind: String = "UWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct UWidget_Previews: PreviewProvider {
    static var previews: some View {
        UWidgetEntryView(entry: SimpleEntry(date: Date(), lesson: Lesson(
            name: "Lesson", start: Date(), end: Date(), professor: "Professor", location: "Main building"), isResponseFromServer: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

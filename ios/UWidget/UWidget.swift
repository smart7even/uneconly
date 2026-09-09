import Foundation
import SwiftUI
import WidgetKit

enum WidgetState {
    case loaded
    case cached
    case unavailable
    case unconfigured
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
    let groupName: String?
    let updatedAt: Date?
    let state: WidgetState
}

struct Provider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.roadmapik.test")

    func placeholder(in context: Context) -> ScheduleEntry {
        Self.previewEntry(at: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (ScheduleEntry) -> Void
    ) {
        if context.isPreview {
            completion(Self.previewEntry(at: Date()))
            return
        }
        completion(cachedEntry(at: Date()) ?? Self.previewEntry(at: Date()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<ScheduleEntry>) -> Void
    ) {
        let now = Date()
        guard
            let groupId = defaults?.object(forKey: "groupId") as? Int,
            groupId > 0
        else {
            let entry = ScheduleEntry(
                date: now,
                lessons: [],
                groupName: nil,
                updatedAt: nil,
                state: .unconfigured
            )
            completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(3_600))))
            return
        }

        let calendar = Calendar.autoupdatingCurrent
        let dayStart = calendar.startOfDay(for: now)
        let repository: ILessonRepository = LessonRepository(
            remoteDataProvider: ServerDataProvider(baseURL: "https://roadmapik.com:5000"),
            localDataProvider: LocalLessonDataProvider()
        )

        repository.fetchData(groupId: groupId, from: dayStart) { result in
            let state: WidgetState = switch result.source {
            case .remote: .loaded
            case .cache: .cached
            case .unavailable: .unavailable
            }
            let groupName = defaults?.string(forKey: "groupName")
            let transitionDates = timelineDates(
                now: now,
                lessons: result.lessons,
                calendar: calendar
            )
            let entries = transitionDates.map { date in
                ScheduleEntry(
                    date: date,
                    lessons: result.lessons,
                    groupName: groupName,
                    updatedAt: result.updatedAt,
                    state: state
                )
            }
            completion(
                Timeline(
                    entries: entries,
                    policy: .after(now.addingTimeInterval(3 * 3_600))
                )
            )
        }
    }

    private func cachedEntry(at date: Date) -> ScheduleEntry? {
        guard
            let groupId = defaults?.object(forKey: "groupId") as? Int,
            groupId > 0,
            let cached = LocalLessonDataProvider().fetchData(groupId: groupId)
        else {
            return nil
        }
        return ScheduleEntry(
            date: date,
            lessons: normalizedWidgetLessons(cached.lessons),
            groupName: defaults?.string(forKey: "groupName"),
            updatedAt: cached.savedDate,
            state: .cached
        )
    }

    static func previewEntry(at date: Date = Date()) -> ScheduleEntry {
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.date(bySettingHour: 11, minute: 20, second: 0, of: date) ?? date
        let second = calendar.date(byAdding: .hour, value: 2, to: start) ?? start
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        let tomorrowSecond = calendar.date(byAdding: .hour, value: 2, to: tomorrow) ?? tomorrow
        return ScheduleEntry(
            date: start.addingTimeInterval(20 * 60),
            lessons: [
                Lesson(
                    name: "Линейная алгебра",
                    day: calendar.startOfDay(for: start),
                    dayOfWeek: "Среда",
                    start: start,
                    end: start.addingTimeInterval(90 * 60),
                    professor: "Гущин А. С.",
                    location: "3117 ауд.",
                    lessonType: "Практика",
                    group: nil
                ),
                Lesson(
                    name: "Микроэкономика",
                    day: calendar.startOfDay(for: second),
                    dayOfWeek: "Среда",
                    start: second,
                    end: second.addingTimeInterval(90 * 60),
                    professor: "Иванова Е. П.",
                    location: "2043 ауд.",
                    lessonType: "Лекция",
                    group: nil
                ),
                Lesson(
                    name: "Сравнительное правоведение",
                    day: calendar.startOfDay(for: tomorrow),
                    dayOfWeek: "Четверг",
                    start: tomorrow,
                    end: tomorrow.addingTimeInterval(90 * 60),
                    professor: "Соколова Мария Викторовна",
                    location: "402 ауд.",
                    lessonType: "Лекция",
                    group: nil
                ),
                Lesson(
                    name: "Международный коммерческий арбитраж",
                    day: calendar.startOfDay(for: tomorrowSecond),
                    dayOfWeek: "Четверг",
                    start: tomorrowSecond,
                    end: tomorrowSecond.addingTimeInterval(90 * 60),
                    professor: "Иванов Илья Сергеевич",
                    location: "208 ауд.",
                    lessonType: "Практика",
                    group: nil
                )
            ],
            groupName: "Э-2601",
            updatedAt: date,
            state: .loaded
        )
    }
}

private func timelineDates(now: Date, lessons: [Lesson], calendar: Calendar) -> [Date] {
    let horizon = calendar.date(byAdding: .day, value: 2, to: now) ?? now.addingTimeInterval(172_800)
    var dates = [now]
    for lesson in lessons where lesson.start < horizon {
        if lesson.start > now { dates.append(lesson.start) }
        if lesson.end > now { dates.append(lesson.end) }
    }
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) {
        dates.append(tomorrow)
    }
    return Array(Set(dates)).sorted()
}

struct UWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ScheduleEntry

    var body: some View {
        Group {
            switch entry.state {
            case .unconfigured:
                MessageView(
                    icon: "person.crop.circle.badge.questionmark",
                    title: "Выберите группу",
                    detail: "Откройте Uneconly и укажите свою группу"
                )
            case .unavailable:
                MessageView(
                    icon: "wifi.slash",
                    title: "Нет данных",
                    detail: "Откройте Uneconly при доступной сети"
                )
            case .loaded, .cached:
                switch family {
                case .systemSmall:
                    DesignSmallScheduleView(entry: entry)
                case .systemLarge:
                    DesignLargeScheduleView(entry: entry)
                default:
                    DesignMediumScheduleView(entry: entry)
                }
            }
        }
        .widgetSurface()
        .widgetURL(URL(string: "https://roadmapik.com/?homeWidget=schedule"))
    }
}

private struct SmallScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let today = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let current = today.first { $0.start <= entry.date && entry.date < $0.end }
        let next = entry.lessons.first { $0.end > entry.date }
        let primary = current ?? next
        let following = primary.flatMap { selected in
            entry.lessons.first { $0.start > selected.start }
        }

        VStack(alignment: .leading, spacing: 7) {
            HeaderView(date: entry.date, trailing: lessonCount(today.count))
            if let primary {
                Text(statusLabel(for: primary, at: entry.date))
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(isCurrent(primary, at: entry.date) ? universityTeal : .secondary)
                Text(primary.displayName)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text("\(time(primary.start)) · \(compactLocation(primary.location))")
                    .font(.system(size: 11, weight: .medium).monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let following {
                    Divider()
                    HStack(spacing: 6) {
                        Text(time(following.start)).monospacedDigit()
                        Text(following.displayName).lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .medium))
                }
            } else {
                Spacer(minLength: 2)
                Text("Пар нет")
                    .font(.system(size: 18, weight: .bold))
                Text("Ближайших занятий пока нет")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer(minLength: 2)
            }
        }
        .padding(14)
    }
}

private struct MediumScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let today = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let lessons = today.filter { $0.end > entry.date }

        VStack(alignment: .leading, spacing: 7) {
            HeaderView(date: entry.date, trailing: entry.groupName ?? "UNEONLY")
            if lessons.isEmpty {
                EmptyDayView(
                    title: today.isEmpty ? "Пар нет" : "На сегодня всё",
                    next: entry.lessons.first { $0.start > entry.date }
                )
            } else {
                ForEach(Array(lessons.prefix(4))) { lesson in
                    LessonRow(lesson: lesson, now: entry.date, expanded: lessons.count <= 2)
                }
                if lessons.count > 4 {
                    Text("Ещё \(lessons.count - 4) \(lessonWord(lessons.count - 4))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            UpdateLabel(entry: entry)
        }
        .padding(14)
    }
}

private struct LargeScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: entry.date) ?? entry.date
        let allToday = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let today = allToday.filter { $0.end > entry.date }
        let tomorrow = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: tomorrowDate) }

        VStack(alignment: .leading, spacing: 7) {
            HeaderView(date: entry.date, trailing: entry.groupName ?? "UNEONLY")
            DaySection(
                title: "СЕГОДНЯ",
                lessons: today,
                limit: 3,
                now: entry.date,
                emptyMessage: allToday.isEmpty ? "Свободный день" : "На сегодня всё"
            )
            Divider()
            DaySection(
                title: "ЗАВТРА",
                lessons: tomorrow,
                limit: 2,
                now: entry.date,
                emptyMessage: "Свободный день"
            )
            Spacer(minLength: 0)
            UpdateLabel(entry: entry)
        }
        .padding(16)
    }
}

private struct HeaderView: View {
    let date: Date
    let trailing: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(dayTitle(date))
                .font(.system(size: 11, weight: .heavy).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .layoutPriority(1)
            Spacer()
            Text(trailing.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

private struct DaySection: View {
    let title: String
    let lessons: [Lesson]
    let limit: Int
    let now: Date
    let emptyMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                Spacer()
                Text(lessonCount(lessons.count))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            if lessons.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 7)
            } else {
                ForEach(Array(lessons.prefix(limit))) { lesson in
                    LessonRow(lesson: lesson, now: now, expanded: false)
                }
                if lessons.count > limit {
                    Text("Ещё \(lessons.count - limit) \(lessonWord(lessons.count - limit))")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let now: Date
    let expanded: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Text(time(lesson.start))
                .font(.system(size: 10, weight: .semibold).monospacedDigit())
                .foregroundStyle(isCurrent(lesson, at: now) ? universityTeal : .secondary)
                .fixedSize(horizontal: true, vertical: false)
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(expanded ? 2 : 1)
                HStack(spacing: 4) {
                    if let lessonType = lesson.lessonType, !lessonType.isEmpty {
                        Text(lessonType)
                    }
                    if !lesson.location.isEmpty {
                        Text(compactLocation(lesson.location))
                    }
                }
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
            Spacer(minLength: 0)
            if isCurrent(lesson, at: now) {
                Text("СЕЙЧАС")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(universityTeal)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, expanded ? 5 : 3)
        .background(
            isCurrent(lesson, at: now) ? currentLessonBackground : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
}

private struct EmptyDayView: View {
    let title: String
    let next: Lesson?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            if let next {
                Text("Ближайшая: \(shortDay(next.start)), \(time(next.start)) · \(next.displayName)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("Ближайших занятий пока нет")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
    }
}

private struct UpdateLabel: View {
    let entry: ScheduleEntry

    var body: some View {
        if let updatedAt = entry.updatedAt {
            Text("\(entry.state == .cached ? "ОФЛАЙН" : "ОБНОВЛЕНО") · \(time(updatedAt))")
                .font(.system(size: 9, weight: .bold).monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

private struct MessageView: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(universityTeal)
            Text(title).font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
    }
}

private let universityTeal = Color(red: 18 / 255, green: 134 / 255, blue: 138 / 255)
private let currentLessonBackground = Color(
    uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 20 / 255, green: 49 / 255, blue: 47 / 255, alpha: 1)
        }
        return UIColor(red: 230 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1)
    }
)

private func isCurrent(_ lesson: Lesson, at date: Date) -> Bool {
    lesson.start <= date && date < lesson.end
}

private func time(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

private func dayTitle(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EE · d MMM"
    return formatter.string(from: date).uppercased()
}

private func shortDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EEEE"
    return formatter.string(from: date)
}

private func compactLocation(_ value: String) -> String {
    value
        .replacingOccurrences(of: "аудитория", with: "ауд.", options: .caseInsensitive)
        .replacingOccurrences(of: "  ", with: " ")
}

private func statusLabel(for lesson: Lesson, at date: Date) -> String {
    if isCurrent(lesson, at: date) { return "ИДЁТ" }
    if !Calendar.autoupdatingCurrent.isDate(lesson.start, inSameDayAs: date) {
        return "ЗАВТРА"
    }
    let minutes = max(1, Int(lesson.start.timeIntervalSince(date) / 60))
    if minutes < 60 { return "ЧЕРЕЗ \(minutes) МИН" }
    return "ЧЕРЕЗ \(minutes / 60) Ч"
}

private func lessonCount(_ count: Int) -> String {
    "\(count) \(lessonWord(count))"
}

private func lessonWord(_ count: Int) -> String {
    let mod100 = count % 100
    let mod10 = count % 10
    if mod100 >= 11 && mod100 <= 14 { return "ПАР" }
    if mod10 == 1 { return "ПАРА" }
    if mod10 >= 2 && mod10 <= 4 { return "ПАРЫ" }
    return "ПАР"
}

private extension View {
    @ViewBuilder
    func widgetSurface() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(.background, for: .widget)
        } else {
            background(Color(uiColor: .systemBackground))
        }
    }
}

struct UWidget: Widget {
    let kind = "UWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Расписание Uneconly")
        .description("Текущая пара, расписание на сегодня и завтра.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct UWidget_Previews: PreviewProvider {
    static var previews: some View {
        UWidgetEntryView(entry: Provider.previewEntry())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        UWidgetEntryView(entry: Provider.previewEntry())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        UWidgetEntryView(entry: Provider.previewEntry())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

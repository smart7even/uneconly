import SwiftUI

// These layouts intentionally mirror the supplied widget design at its native
// 158/338 pt sizes. WidgetKit's automatic iOS 17 margins are disabled by the
// configuration, so every inset below is owned by the design.

struct DesignSmallScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let today = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let current = today.first { designIsCurrent($0, at: entry.date) }
        let next = entry.lessons.first { $0.start > entry.date }
        let primary = current ?? next
        let displayDate = primary?.start ?? entry.date
        let displayLessons = entry.lessons.filter {
            calendar.isDate($0.start, inSameDayAs: displayDate)
        }
        let following = primary.flatMap { selected in
            entry.lessons.first { $0.start > selected.start }
        }

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(designShortDate(displayDate))
                Spacer(minLength: 5)
                if !displayLessons.isEmpty {
                    Text(designLessonCount(displayLessons.count))
                }
            }
            .font(designMono(9, "SemiBold"))
            .tracking(0.7)
            .foregroundStyle(designMuted)
            .lineLimit(1)

            if let primary {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(designTime(primary.start))
                        .font(designMono(16, "SemiBold"))
                        .foregroundStyle(designIsCurrent(primary, at: entry.date) ? designTeal : designInk)
                    Text(designStatus(for: primary, at: entry.date))
                        .font(designMono(8.5, "SemiBold"))
                        .tracking(0.7)
                        .foregroundStyle(designIsCurrent(primary, at: entry.date) ? designTeal : designMuted)
                }
                .padding(.top, 11)

                Text(primary.displayName)
                    .font(designSans(11.5, "SemiBold"))
                    .foregroundStyle(designInk)
                    .lineLimit(2)
                    .padding(.top, 5)

                Text(designSmallMetadata(primary))
                    .font(designSans(10))
                    .foregroundStyle(designMuted)
                    .lineLimit(1)
                    .padding(.top, 3)

                Spacer(minLength: 4)

                if let following {
                    designDivider
                    HStack(spacing: 7) {
                        Text(designTime(following.start))
                            .font(designMono(9.5, "Medium"))
                            .foregroundStyle(designMuted)
                            .fixedSize()
                        Text(following.displayName)
                            .font(designSans(10, "Medium"))
                            .foregroundStyle(designBody)
                            .lineLimit(1)
                    }
                    .padding(.top, 7)
                }
            } else {
                Spacer(minLength: 8)
                Text("Пар нет")
                    .font(designSans(12.5, "SemiBold"))
                    .foregroundStyle(designInk)
                Text("Ближайших занятий пока нет")
                    .font(designSans(10.5))
                    .foregroundStyle(designMuted)
                    .lineLimit(2)
                    .padding(.top, 5)
                Spacer(minLength: 8)
            }
        }
        .padding(14)
    }
}

struct DesignMediumScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let lessons = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let detailed = lessons.count <= 2
        let visibleLimit = lessons.count > 4 ? 3 : 4

        VStack(alignment: .leading, spacing: 0) {
            DesignMediumHeader(entry: entry, lessons: lessons)
                .padding(.bottom, 4)

            if lessons.isEmpty {
                DesignEmptyDay(next: entry.lessons.first { $0.start > entry.date })
            } else {
                ForEach(Array(lessons.prefix(visibleLimit))) { lesson in
                    if detailed {
                        DesignDetailedLessonRow(
                            lesson: lesson,
                            now: entry.date,
                            edgeInset: 16,
                            includeProfessor: false
                        )
                    } else {
                        DesignCompactLessonRow(lesson: lesson, now: entry.date, edgeInset: 16)
                    }
                }
                if lessons.count > visibleLimit {
                    DesignOverflowRow(
                        count: lessons.count - visibleLimit,
                        lastEnd: lessons.last?.end
                    )
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

private struct DesignMediumHeader: View {
    let entry: ScheduleEntry
    let lessons: [Lesson]

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(designFullDate(entry.date).uppercased())
                .font(designMono(10, "SemiBold"))
                .foregroundStyle(designInk)
                .layoutPriority(2)
            if let groupName = entry.groupName {
                Text(groupName.uppercased())
                    .font(designMono(10, "Medium"))
                    .foregroundStyle(designMuted)
            }
            Spacer(minLength: 6)
            if let last = lessons.last {
                Text("\(designLessonCount(lessons.count)) · ДО \(designTime(last.end))")
                    .font(designMono(9.5, "SemiBold"))
                    .foregroundStyle(designMuted)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .tracking(0.7)
        .lineLimit(1)
    }
}

struct DesignLargeScheduleView: View {
    let entry: ScheduleEntry

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: entry.date) ?? entry.date
        let allToday = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: entry.date) }
        let remainingToday = allToday.filter { $0.end > entry.date }
        let tomorrow = entry.lessons.filter { calendar.isDate($0.start, inSameDayAs: tomorrowDate) }
        let todayDetailed = remainingToday.count <= 2
        let todayLimit = todayDetailed ? 2 : 4
        let tomorrowLimit = remainingToday.isEmpty ? 4 : 3

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(designLargeDate(entry.date))
                    .font(designSans(15, "Bold"))
                    .foregroundStyle(designInk)
                    .lineLimit(1)
                    .layoutPriority(2)
                Spacer(minLength: 8)
                if let groupName = entry.groupName {
                    Text(groupName.uppercased())
                        .font(designMono(10, "Medium"))
                        .tracking(0.7)
                        .foregroundStyle(designMuted)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }

            DesignTodayStatus(
                hadLessons: !allToday.isEmpty,
                remainingCount: remainingToday.count
            )

            ForEach(Array(remainingToday.prefix(todayLimit))) { lesson in
                if todayDetailed {
                    DesignDetailedLessonRow(
                        lesson: lesson,
                        now: entry.date,
                        edgeInset: 16,
                        includeProfessor: true
                    )
                } else {
                    DesignCompactLessonRow(lesson: lesson, now: entry.date, edgeInset: 16)
                }
            }
            if remainingToday.count > todayLimit {
                DesignOverflowRow(
                    count: remainingToday.count - todayLimit,
                    lastEnd: allToday.last?.end
                )
            }

            Text("ЗАВТРА · \(designCalendarDate(tomorrowDate).uppercased())")
                .font(designMono(9.5, "SemiBold"))
                .tracking(0.8)
                .foregroundStyle(designMuted)
                .padding(.top, 12)
                .padding(.bottom, 6)

            if tomorrow.isEmpty {
                Text("Свободный день")
                    .font(designSans(12, "Medium"))
                    .foregroundStyle(designMuted)
                    .padding(.vertical, 7)
            } else {
                ForEach(Array(tomorrow.prefix(tomorrowLimit))) { lesson in
                    DesignCompactLessonRow(lesson: lesson, now: entry.date, edgeInset: 16)
                }
                if tomorrow.count > tomorrowLimit {
                    DesignOverflowRow(
                        count: tomorrow.count - tomorrowLimit,
                        lastEnd: tomorrow.last?.end
                    )
                }
            }

            Spacer(minLength: 0)
            DesignLargeFooter(entry: entry)
        }
        .padding(16)
    }
}

private struct DesignTodayStatus: View {
    let hadLessons: Bool
    let remainingCount: Int

    var body: some View {
        HStack(spacing: 7) {
            Text("СЕГОДНЯ")
                .foregroundStyle(designTeal)
            Circle()
                .fill(designTeal)
                .frame(width: 5, height: 5)
            Text(status)
                .foregroundStyle(designMuted)
        }
        .font(designMono(9.5, "SemiBold"))
        .tracking(0.8)
        .padding(.top, 11)
        .padding(.bottom, 6)
    }

    private var status: String {
        if remainingCount > 0 { return "ОСТАЛОСЬ \(remainingCount)" }
        return hadLessons ? "ПАРЫ ЗАКОНЧИЛИСЬ" : "СВОБОДНЫЙ ДЕНЬ"
    }
}

private struct DesignDetailedLessonRow: View {
    let lesson: Lesson
    let now: Date
    let edgeInset: CGFloat
    let includeProfessor: Bool

    var body: some View {
        VStack(spacing: 0) {
            designDivider
            HStack(alignment: .top, spacing: 12) {
                Text("\(designTime(lesson.start))\n\(designTime(lesson.end))")
                    .font(designMono(11, "Medium"))
                    .foregroundStyle(designIsCurrent(lesson, at: now) ? designTeal : designMuted)
                    .lineSpacing(1.5)
                    .frame(width: 42, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.displayName)
                        .font(designSans(12.5, "SemiBold"))
                        .foregroundStyle(designInk)
                        .lineLimit(2)
                    Text(designLessonMetadata(lesson, includeProfessor: includeProfessor))
                        .font(designSans(10.5))
                        .foregroundStyle(designBody)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if designIsCurrent(lesson, at: now) {
                    Text("ИДЁТ")
                        .font(designMono(9, "SemiBold"))
                        .tracking(0.7)
                        .foregroundStyle(designTeal)
                        .padding(.top, 3)
                } else if !includeProfessor {
                    Text(designRoom(lesson.location))
                        .font(designMono(10))
                        .foregroundStyle(designMuted)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 7)
        }
        .padding(.horizontal, designIsCurrent(lesson, at: now) ? edgeInset : 0)
        .background(designIsCurrent(lesson, at: now) ? designCurrentBackground : Color.clear)
        .padding(.horizontal, designIsCurrent(lesson, at: now) ? -edgeInset : 0)
    }
}

private struct DesignCompactLessonRow: View {
    let lesson: Lesson
    let now: Date
    let edgeInset: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            designDivider
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(designTime(lesson.start))
                    .font(designMono(11, "Medium"))
                    .foregroundStyle(designIsCurrent(lesson, at: now) ? designTeal : designMuted)
                    .frame(width: 42, alignment: .leading)
                Text(lesson.displayName)
                    .font(designSans(12, "SemiBold"))
                    .foregroundStyle(designInk)
                    .lineLimit(1)
                Spacer(minLength: 2)
                Text(designIsCurrent(lesson, at: now) ? "ИДЁТ" : designRoom(lesson.location))
                    .font(designMono(designIsCurrent(lesson, at: now) ? 9 : 10, "Medium"))
                    .tracking(designIsCurrent(lesson, at: now) ? 0.7 : 0)
                    .foregroundStyle(designIsCurrent(lesson, at: now) ? designTeal : designMuted)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 7)
        }
        .padding(.horizontal, designIsCurrent(lesson, at: now) ? edgeInset : 0)
        .background(designIsCurrent(lesson, at: now) ? designCurrentBackground : Color.clear)
        .padding(.horizontal, designIsCurrent(lesson, at: now) ? -edgeInset : 0)
    }
}

private struct DesignOverflowRow: View {
    let count: Int
    let lastEnd: Date?

    var body: some View {
        VStack(spacing: 0) {
            designDivider
            HStack {
                Text("ЕЩЁ \(designLessonCount(count))")
                Spacer()
                if let lastEnd { Text("ДО \(designTime(lastEnd))") }
            }
            .font(designMono(10, "Medium"))
            .tracking(0.5)
            .foregroundStyle(designMuted)
            .padding(.vertical, 7)
        }
    }
}

private struct DesignEmptyDay: View {
    let next: Lesson?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Spacer(minLength: 4)
            Text("Пар нет")
                .font(designSans(13, "SemiBold"))
                .foregroundStyle(designInk)
            if let next {
                Text("Ближайшая — \(designShortDay(next.start)), \(designTime(next.start))")
                    .font(designSans(10.5))
                    .foregroundStyle(designMuted)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
        }
        .frame(maxHeight: .infinity)
    }
}

private struct DesignLargeFooter: View {
    let entry: ScheduleEntry

    var body: some View {
        VStack(spacing: 0) {
            designDivider
            HStack(alignment: .firstTextBaseline) {
                if let updatedAt = entry.updatedAt {
                    Text("\(entry.state == .cached ? "ОФЛАЙН" : "ОБНОВЛЕНО") \(designTime(updatedAt))")
                        .font(designMono(9.5))
                        .tracking(0.5)
                        .foregroundStyle(designMuted)
                }
                Spacer()
                Text("Вся неделя")
                    .font(designSans(10.5, "SemiBold"))
                    .foregroundStyle(designTeal)
            }
            .padding(.top, 7)
        }
    }
}

private let designTeal = Color(red: 18 / 255, green: 134 / 255, blue: 138 / 255)
private let designInk = designAdaptiveColor(light: (34, 41, 42), dark: (236, 239, 239))
private let designBody = designAdaptiveColor(light: (60, 68, 69), dark: (201, 207, 207))
private let designMuted = designAdaptiveColor(light: (110, 118, 119), dark: (139, 147, 148))
private let designHairline = designAdaptiveColor(light: (227, 233, 233), dark: (42, 46, 47))
private let designCurrentBackground = designAdaptiveColor(light: (230, 241, 241), dark: (20, 49, 47))

private var designDivider: some View {
    Rectangle().fill(designHairline).frame(height: 0.5)
}

private func designAdaptiveColor(
    light: (CGFloat, CGFloat, CGFloat),
    dark: (CGFloat, CGFloat, CGFloat)
) -> Color {
    Color(uiColor: UIColor { traits in
        let components = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(
            red: components.0 / 255,
            green: components.1 / 255,
            blue: components.2 / 255,
            alpha: 1
        )
    })
}

private func designSans(_ size: CGFloat, _ face: String = "Regular") -> Font {
    .custom("Montserrat-\(face)", fixedSize: size)
}

private func designMono(_ size: CGFloat, _ face: String = "Regular") -> Font {
    .custom("JetBrainsMono-\(face)", fixedSize: size)
}

private func designIsCurrent(_ lesson: Lesson, at date: Date) -> Bool {
    lesson.start <= date && date < lesson.end
}

private func designTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

private func designShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EE"
    let weekday = formatter.string(from: date).replacingOccurrences(of: ".", with: "").uppercased()
    formatter.dateFormat = "d"
    let day = formatter.string(from: date)
    formatter.dateFormat = "MMM"
    let month = formatter.string(from: date)
        .replacingOccurrences(of: ".", with: "")
        .prefix(3)
        .uppercased()
    return "\(weekday) · \(day) \(month)"
}

private func designFullDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EEEE · d MMMM"
    return formatter.string(from: date)
}

private func designLargeDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EEEE, d MMMM"
    let value = formatter.string(from: date)
    return value.prefix(1).uppercased() + value.dropFirst()
}

private func designCalendarDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "d MMMM"
    return formatter.string(from: date)
}

private func designShortDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "EEEE"
    return formatter.string(from: date)
}

private func designCompactLocation(_ value: String) -> String {
    value
        .replacingOccurrences(of: "аудитория", with: "ауд.", options: .caseInsensitive)
        .replacingOccurrences(of: "  ", with: " ")
}

private func designShortLocation(_ value: String) -> String {
    let compact = designCompactLocation(value)
    guard let range = compact.range(of: "ауд.", options: .caseInsensitive) else {
        return compact
    }
    return String(compact[..<range.upperBound])
}

private func designRoom(_ value: String) -> String {
    if value.localizedCaseInsensitiveContains("вариант") { return "ПОДГРУППЫ" }
    return value.split(separator: " ").first.map(String.init) ?? ""
}

private func designProfessor(_ value: String?) -> String? {
    guard let value, !value.isEmpty else { return nil }
    let parts = value.split(separator: " ")
    guard parts.count >= 2 else { return value }
    let initials = parts.dropFirst().prefix(2).compactMap { $0.first }.map { "\($0)." }.joined(separator: " ")
    return "\(parts[0]) \(initials)"
}

private func designSmallMetadata(_ lesson: Lesson) -> String {
    [lesson.lessonType, designShortLocation(lesson.location)]
        .compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        .joined(separator: " · ")
}

private func designLessonMetadata(_ lesson: Lesson, includeProfessor: Bool) -> String {
    var values: [String?] = [lesson.lessonType, designCompactLocation(lesson.location)]
    if includeProfessor { values.append(designProfessor(lesson.professor)) }
    return values.compactMap { value in
        guard let value, !value.isEmpty else { return nil }
        return value
    }.joined(separator: " · ")
}

private func designStatus(for lesson: Lesson, at date: Date) -> String {
    if designIsCurrent(lesson, at: date) { return "ИДЁТ" }
    if !Calendar.autoupdatingCurrent.isDate(lesson.start, inSameDayAs: date) {
        return "ЗАВТРА"
    }
    let minutes = max(1, Int(lesson.start.timeIntervalSince(date) / 60))
    if minutes < 60 { return "ЧЕРЕЗ \(minutes) МИН" }
    return "ЧЕРЕЗ \(minutes / 60) Ч"
}

private func designLessonCount(_ count: Int) -> String {
    "\(count) \(designLessonWord(count))"
}

private func designLessonWord(_ count: Int) -> String {
    let mod100 = count % 100
    let mod10 = count % 10
    if mod100 >= 11 && mod100 <= 14 { return "ПАР" }
    if mod10 == 1 { return "ПАРА" }
    if mod10 >= 2 && mod10 <= 4 { return "ПАРЫ" }
    return "ПАР"
}

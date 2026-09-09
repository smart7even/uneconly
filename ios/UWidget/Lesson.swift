import Foundation

struct Lesson: Codable, Identifiable, Hashable {
    let name: String
    let day: Date
    let dayOfWeek: String
    let start: Date
    let end: Date
    let professor: String?
    let location: String
    let lessonType: String?
    let group: String?

    var id: String {
        "\(start.timeIntervalSince1970)-\(end.timeIntervalSince1970)-\(name)-\(location)"
    }

    var displayName: String {
        guard let lessonType, !lessonType.isEmpty else { return name }
        let suffix = " (\(lessonType))"
        guard name.lowercased().hasSuffix(suffix.lowercased()) else { return name }
        return String(name.dropLast(suffix.count))
    }

    enum CodingKeys: String, CodingKey {
        case name
        case day
        case dayOfWeek = "day_of_week"
        case start
        case end
        case professor
        case location
        case lessonType = "lesson_type"
        case group
    }
}

func normalizedWidgetLessons(_ lessons: [Lesson]) -> [Lesson] {
    struct Slot: Hashable {
        let start: Date
        let end: Date
        let name: String
        let lessonType: String?
    }

    let grouped = Dictionary(grouping: lessons) { lesson in
        Slot(
            start: lesson.start,
            end: lesson.end,
            name: lesson.displayName.lowercased(),
            lessonType: lesson.lessonType?.lowercased()
        )
    }

    return grouped.values.compactMap { alternatives in
        guard let first = alternatives.first else { return nil }
        guard alternatives.count > 1 else { return first }
        return Lesson(
            name: first.displayName,
            day: first.day,
            dayOfWeek: first.dayOfWeek,
            start: first.start,
            end: first.end,
            professor: nil,
            location: "\(alternatives.count) вариантов подгрупп",
            lessonType: first.lessonType,
            group: first.group
        )
    }
    .sorted { lhs, rhs in
        if lhs.start != rhs.start { return lhs.start < rhs.start }
        return lhs.displayName < rhs.displayName
    }
}

enum WidgetDateCoding {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: value) {
                return date
            }
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: value) {
                return date
            }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
            for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
                formatter.dateFormat = format
                if let date = formatter.date(from: value) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported lesson date: \(value)"
            )
        }
        return decoder
    }
}

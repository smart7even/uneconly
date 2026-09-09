import Foundation

private let widgetAppGroup = "group.roadmapik.test"

struct LessonResponse: Codable {
    let lessons: [Lesson]
}

protocol DataProvider {
    func fetchData(
        groupId: Int,
        from dayStart: Date,
        completion: @escaping (Result<[Lesson], Error>) -> Void
    )
}

enum WidgetNetworkError: Error {
    case invalidURL
    case invalidResponse
}

final class ServerDataProvider: DataProvider {
    private let baseURL: String
    private let session: URLSession

    init(baseURL: String) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 10
        configuration.waitsForConnectivity = false
        session = URLSession(configuration: configuration)
    }

    func fetchData(
        groupId: Int,
        from dayStart: Date,
        completion: @escaping (Result<[Lesson], Error>) -> Void
    ) {
        guard var components = URLComponents(
            string: "\(baseURL)/group/\(groupId)/lessons/next"
        ) else {
            completion(.failure(WidgetNetworkError.invalidURL))
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        components.queryItems = [
            URLQueryItem(name: "after_date", value: formatter.string(from: dayStart))
        ]

        guard let url = components.url else {
            completion(.failure(WidgetNetworkError.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data
            else {
                completion(.failure(WidgetNetworkError.invalidResponse))
                return
            }

            do {
                let response = try WidgetDateCoding.decoder().decode(
                    LessonResponse.self,
                    from: data
                )
                completion(.success(response.lessons.sorted { $0.start < $1.start }))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct LessonsRecord: Codable {
    let lessons: [Lesson]
    let savedDate: Date
    let groupId: Int
}

protocol ILocalLessonDataProvider {
    func fetchData(groupId: Int) -> LessonsRecord?
    func saveData(_ record: LessonsRecord)
}

final class LocalLessonDataProvider: ILocalLessonDataProvider {
    private let defaults = UserDefaults(suiteName: widgetAppGroup)

    func fetchData(groupId: Int) -> LessonsRecord? {
        guard let data = defaults?.data(forKey: key(groupId: groupId)) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(LessonsRecord.self, from: data)
        } catch {
            return nil
        }
    }

    func saveData(_ record: LessonsRecord) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            defaults?.set(try encoder.encode(record), forKey: key(groupId: record.groupId))
        } catch {
            // The widget remains useful with the in-memory response even if a
            // cache write fails; WidgetKit will request another timeline later.
        }
    }

    private func key(groupId: Int) -> String {
        "widgetLessons.v2.\(groupId)"
    }
}

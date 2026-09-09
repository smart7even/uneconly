import Foundation

enum WidgetDataSource {
    case remote
    case cache
    case unavailable
}

struct WidgetLessonResult {
    let lessons: [Lesson]
    let updatedAt: Date?
    let source: WidgetDataSource
}

protocol ILessonRepository {
    func fetchData(
        groupId: Int,
        from dayStart: Date,
        completion: @escaping (WidgetLessonResult) -> Void
    )
}

final class LessonRepository: ILessonRepository {
    private let remoteDataProvider: DataProvider
    private let localDataProvider: ILocalLessonDataProvider

    init(
        remoteDataProvider: DataProvider,
        localDataProvider: ILocalLessonDataProvider
    ) {
        self.remoteDataProvider = remoteDataProvider
        self.localDataProvider = localDataProvider
    }

    func fetchData(
        groupId: Int,
        from dayStart: Date,
        completion: @escaping (WidgetLessonResult) -> Void
    ) {
        remoteDataProvider.fetchData(groupId: groupId, from: dayStart) { result in
            switch result {
            case .success(let lessons):
                let normalizedLessons = normalizedWidgetLessons(lessons)
                let savedDate = Date()
                self.localDataProvider.saveData(
                    LessonsRecord(
                        lessons: normalizedLessons,
                        savedDate: savedDate,
                        groupId: groupId
                    )
                )
                completion(
                    WidgetLessonResult(
                        lessons: normalizedLessons,
                        updatedAt: savedDate,
                        source: .remote
                    )
                )
            case .failure:
                if let cached = self.localDataProvider.fetchData(groupId: groupId) {
                    completion(
                        WidgetLessonResult(
                            lessons: normalizedWidgetLessons(cached.lessons),
                            updatedAt: cached.savedDate,
                            source: .cache
                        )
                    )
                } else {
                    completion(
                        WidgetLessonResult(
                            lessons: [],
                            updatedAt: nil,
                            source: .unavailable
                        )
                    )
                }
            }
        }
    }
}

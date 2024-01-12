//
//  LessonRepository.swift
//  Runner
//
//  Created by Oleg on 12.01.2024.
//

import Foundation

protocol ILessonRepository {
    func fetchData(groupId: Int, completion: @escaping (Lesson?) -> Void)
}

class LessonRepository : ILessonRepository {
    let remoteDataProvider: DataProvider
    let localDataProvider: ILocalLessonDataProvider
    
    init(remoteDataProvider: DataProvider, localDataProvider: ILocalLessonDataProvider) {
        self.remoteDataProvider = remoteDataProvider
        self.localDataProvider = localDataProvider
    }
    
    func fetchData(groupId: Int, completion: @escaping (Lesson?) -> Void) {
        self.remoteDataProvider.fetchData(groupId: groupId) { lessons in
            if (lessons == nil) {
                let lessonsRecord = self.localDataProvider.fetchData(groupId: groupId)
                
                if (lessonsRecord == nil) {
                    completion(nil)
                    return
                }
                
                let lessons = lessonsRecord?.lessons
                
                if (lessons == nil || lessons?.isEmpty ?? true) {
                    completion(nil)
                    return
                }
                
                completion(lessons?.first)
                return
            }
            
            if let lessons = lessons {
                let lessonsRecord = LessonsRecord(
                    lessons: lessons, savedDate: Date(), groupId: groupId
                )
                
                self.localDataProvider.saveData(lessonsRecord: lessonsRecord)
                
                completion(lessons.first)
            }
        }
    }
}

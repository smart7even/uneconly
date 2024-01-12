//
//  LessonDataProvider.swift
//  Runner
//
//  Created by Oleg on 20.08.2023.
//

import Foundation

enum DateError: String, Error {
    case invalidDate
}

struct LessonResponse: Codable {
    let lessons: [Lesson]
}

protocol DataProvider {
    func fetchData(groupId: Int, completion: @escaping ([Lesson]?) -> Void)
    // Add any other methods or properties that the data provider should have.
}

class ServerDataProvider: DataProvider {
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func fetchData(groupId: Int, completion: @escaping ([Lesson]?) -> Void) {
        // Create a URL object
        guard let url = URL(string: "\(baseURL)/group/\(groupId)/lessons/next") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle data, errors, etc.
            // For example, you can decode the data into a Lesson object and pass it to the completion handler.

            if let error = error {
                print("Error fetching data: \(error)")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.timeZone = TimeZone(secondsFromGMT: 3600 * 3)
                    
                    if let stringContent = String(data: data, encoding: .utf8) {
                            print(stringContent)
                        } else {
                            print("Failed to convert data to string.")
                        }
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)

                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        
                        throw DateError.invalidDate
                    })
                    let lessonResponse = try decoder.decode(LessonResponse.self, from: data)
                    
                    completion(lessonResponse.lessons)
                } catch {
                    print("Decoding error: \(error)")
                    completion(nil)
                }
            } else {
                print("Invalid data")
                completion(nil)
            }
        }

        // Start the task
        task.resume()
    }

    // Implement any other methods from the DataProvider protocol.
}

extension FileManager {
    static func documentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


struct LessonsRecord: Codable {
    let lessons: [Lesson]
    let savedDate: Date
    let groupId: Int
}

protocol ILocalLessonDataProvider {
    func fetchData(groupId: Int) -> LessonsRecord?
    func saveData(lessonsRecord: LessonsRecord)
}

class LocalLessonDataProvider: ILocalLessonDataProvider {
    func fetchData(groupId: Int) -> LessonsRecord? {
        let url = getUrl(groupId: groupId)
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(LessonsRecord.self, from: data)
        } catch {
            print("Error loading lessons from LocalLessonDataProvider: \(error)")
            return nil
        }
    }
    
    func saveData(lessonsRecord: LessonsRecord) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(lessonsRecord)
            let url = getUrl(groupId: lessonsRecord.groupId)
            try data.write(to: url)
        } catch {
            print("Error saving lessons to LocalLessonDataProvider: \(error)")
        }
    }
    
    func getUrl(groupId: Int) -> URL {
        return FileManager.documentsDirectory().appendingPathComponent("lessons_\(groupId)")
    }
}


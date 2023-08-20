//
//  lesson.swift
//  Runner
//
//  Created by Oleg on 20.08.2023.
//

import Foundation

struct Lesson: Codable {
    let name: String
//    let day: Date
//    let dayOfWeek: String
    let start: Date
    let end: Date
    let professor: String?
    let location: String

    enum CodingKeys: String, CodingKey {
        case name
//        case day
//        case dayOfWeek = "day_of_week"
        case start
        case end
        case professor
        case location
    }

    // If you need custom decoding or encoding, you can implement `init(from decoder: Decoder)` and `encode(to encoder: Encoder)` methods. But for this structure, the default Codable implementations should suffice.
}

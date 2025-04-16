//
//  Tracker.swift
//  Tracker
//
//  Created by Yana Silosieva on 25.02.2025.
//

import UIKit

struct Tracker: Identifiable, Codable {
    let id: UUID
    let title: String
    let color: CodableColor
    let emoji: String
    let schedule: [Weekdays]
    let explicitDate: Date?
}

@propertyWrapper
struct CodableColor {
    var wrappedValue: UIColor
}

extension CodableColor: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid color"
            )
        }
        wrappedValue = color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
}

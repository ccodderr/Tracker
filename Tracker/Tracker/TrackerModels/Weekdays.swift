//
//  Weekdays.swift
//  Tracker
//
//  Created by Yana Silosieva on 14.04.2025.
//

enum Weekdays: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    static func from(_ weekdayNumber: Int) -> Weekdays? {
        return Weekdays.allCases.first { $0.number == weekdayNumber }
    }

    var number: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
}


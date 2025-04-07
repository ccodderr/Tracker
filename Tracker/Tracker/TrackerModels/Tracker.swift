//
//  Tracker.swift
//  Tracker
//
//  Created by Yana Silosieva on 25.02.2025.
//

import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekdays]
    let explictDate: Date?
}

enum TrackerType {
    case habit
    case irregularEvent
}

enum Weekdays: String, CaseIterable {
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



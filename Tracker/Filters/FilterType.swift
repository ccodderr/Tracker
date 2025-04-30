//
//  FilterType.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

enum FilterType: Int, CaseIterable {
    case allTrackers
    case todaysTrackers
    case completedTrackers
    case notCompletedTrackers
    
    var title: String {
        switch self {
        case .allTrackers: "Все трекеры"
        case .todaysTrackers: "Трекеры на сегодня"
        case .completedTrackers: "Завершенные"
        case .notCompletedTrackers: "Не завершенные"
        }
    }
}

//
//  FilterType.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

enum FilterType: Int, CaseIterable {
    case allTrackers = 0
    case todaysTrackers = 1
    case completedTrackers = 2
    case notCompletedTrackers = 3
    
    var title: String {
        switch self {
        case .allTrackers:
            return "Все трекеры"
        case .todaysTrackers:
            return "Трекеры на сегодня"
        case .completedTrackers:
            return "Завершенные"
        case .notCompletedTrackers:
            return "Не завершенные"
        }
    }
}

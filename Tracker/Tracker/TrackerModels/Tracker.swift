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
    let explicitDate: Date?
}

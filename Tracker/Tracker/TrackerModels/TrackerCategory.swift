//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Yana Silosieva on 25.02.2025.
//

import Foundation

struct Category: Equatable, Hashable {
    let title: String
    let id: UUID
    
    init(title: String, id: UUID) {
        self.title = title
        self.id = id
    }
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

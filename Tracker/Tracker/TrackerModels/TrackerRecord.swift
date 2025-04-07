//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Yana Silosieva on 25.02.2025.
//

import Foundation

struct TrackerRecord: Hashable, Equatable {
    let trackerId: UUID
    let date: Date
    
    static func ==(lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY"
        let lhsDate = dateFormatter.string(from: lhs.date)
        let rhsDate = dateFormatter.string(from: rhs.date)
        
        return lhs.trackerId == rhs.trackerId && lhsDate == rhsDate
    }
}

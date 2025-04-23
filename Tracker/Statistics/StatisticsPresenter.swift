//
//  StatisticsPresenter.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

import Foundation

protocol StatisticsPresenterProtocol: AnyObject {
    var view: StatisticsViewControllerProtocol? { get set }
    func viewDidLoad()
    func calculateBestPeriod() -> Int
    func calculatePerfectDays() -> Int
    func calculateCompletedTrackers() -> Int
    func calculateAverageCompletions() -> Int
    func hasData() -> Bool
}

final class StatisticsPresenter: StatisticsPresenterProtocol, TrackerRecordStoreDelegate {
    weak var view: StatisticsViewControllerProtocol?
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    init(
        trackerStore: TrackerStore = TrackerStore(),
        recordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.recordStore.delegate = self
    }
    
    func viewDidLoad() {
        view?.updateUIState(hasData())
        view?.reloadStatistics()
    }
    
    func hasData() -> Bool {
        return !recordStore.records.isEmpty
    }
    
    func calculateBestPeriod() -> Int {
        let records = recordStore.records.sorted { $0.date < $1.date }
        guard !records.isEmpty else { return 0 }
        
        var bestStreak = 0
        var currentStreak = 1
        let calendar = Calendar.current
        
        var dateSet = Set<Date>()
        for record in records {
            let components = calendar.dateComponents(
                [
                    .year,
                    .month,
                    .day
                ],
                from: record.date
            )
            if let normalizedDate = calendar.date(from: components) {
                dateSet.insert(normalizedDate)
            }
        }
        
        let sortedDates = dateSet.sorted()
        guard !sortedDates.isEmpty else { return 0 }
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i-1]
            let currentDate = sortedDates[i]
            
            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day, daysBetween == 1 {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return max(bestStreak, 1)
    }
    
    func calculatePerfectDays() -> Int {
        let records = recordStore.records
        guard !records.isEmpty else { return 0 }
        
        var recordsByDate: [Date: [TrackerRecord]] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let components = calendar.dateComponents([.year, .month, .day], from: record.date)
            if let normalizedDate = calendar.date(from: components) {
                if recordsByDate[normalizedDate] == nil {
                    recordsByDate[normalizedDate] = []
                }
                recordsByDate[normalizedDate]?.append(record)
            }
        }
        
        var perfectDays = 0
        
        for (date, dateRecords) in recordsByDate {
            let plannedTrackers = getAllPlannedTrackersForDate(date)
            let completedTrackerIds = Set(dateRecords.map { $0.trackerId })
            
            if !plannedTrackers.isEmpty
                && plannedTrackers.allSatisfy({ completedTrackerIds.contains($0.id) }) {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }
    
    func calculateCompletedTrackers() -> Int {
        return recordStore.records.count
    }
    
    func calculateAverageCompletions() -> Int {
        let records = recordStore.records
        guard !records.isEmpty else { return 0 }
        
        var recordsByDate: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for record in records {
            let components = calendar.dateComponents([.year, .month, .day], from: record.date)
            if let normalizedDate = calendar.date(from: components) {
                recordsByDate[normalizedDate, default: 0] += 1
            }
        }
        
        let totalDays = recordsByDate.count
        let totalCompletions = records.count
        
        return Int(
            totalDays > 0 ? Double(totalCompletions) / Double(totalDays) : 0
        )
    }
    
    private func getAllPlannedTrackersForDate(_ date: Date) -> [Tracker] {
        let trackers = trackerStore.trackers
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        guard let weekday = Weekdays.from(weekdayNumber) else { return [] }
        
        return trackers.filter { tracker in
            if let explicitDate = tracker.explicitDate {
                return calendar.isDate(explicitDate, inSameDayAs: date)
            } else {
                return tracker.schedule.contains(weekday)
            }
        }
    }
    
    // MARK: - TrackerRecordStoreDelegate
    func didUpdateRecords() {
        view?.updateUIState(hasData())
        view?.reloadStatistics()
    }
}

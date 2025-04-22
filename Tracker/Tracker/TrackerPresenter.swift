//
//  TrackerPresenter.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import Foundation

// MARK: - View Protocol
protocol TrackersPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    func viewDidLoad()
    func dateChanged(to date: Date)
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date)
    func addTracker(_ tracker: Tracker)
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool
    func isEditableDate(_ date: Date) -> Bool
    func getCompletedTrackerCount(_ tracker: Tracker) -> Int
}

// MARK: - Presenter
final class TrackersPresenter: TrackersPresenterProtocol {
    
    weak var view: (any TrackersViewControllerProtocol)?
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private var currentDate: Date = Date()
    
    init(
        trackerStore: TrackerStore = TrackerStore(),
        recordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        trackerStore.delegate = self
        recordStore.delegate = self
    }
    
    func viewDidLoad() {
        categories = categorize(trackers: trackerStore.trackers)
        dateChanged(to: currentDate)
    }
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    private func categorize(trackers: [Tracker]) -> [TrackerCategory] {
        var categoriesDict: [UUID: [Tracker]] = [:]
        
        for tracker in trackers {
            let categoryId = tracker.category.id ?? .init()
            
            if categoriesDict[categoryId] == nil {
                categoriesDict[categoryId] = [tracker]
            } else {
                categoriesDict[categoryId]?.append(tracker)
            }
        }
        
        var result: [TrackerCategory] = []
        
        for (_, categoryTrackers) in categoriesDict {
            if let firstTracker = categoryTrackers.first {
                let category = TrackerCategory(
                    title: firstTracker.category.title ?? "",
                    trackers: categoryTrackers
                )
                
                result.append(category)
            }
        }
        
        return result
    }
    
    func isEditableDate(_ date: Date) -> Bool {
        date <= Date()
    }
    
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool {
        recordStore.isCompleted(tracker, on: date)
    }
    
    func getCompletedTrackerCount(_ tracker: Tracker) -> Int {
        recordStore.getCountOf(tracker)
    }
    
    func dateChanged(to date: Date) {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        guard let selectedWeekday = Weekdays.from(weekdayNumber) else { return }
        
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.explicitDate != nil {
                    return Calendar.current.isDateInToday(date)
                }
                return tracker.schedule.contains(selectedWeekday)
            }
            return TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }.filter { !$0.trackers.isEmpty }
        
        view?.updateTrackers(filteredCategories)
        currentDate = date
    }
    
    // MARK: - Tracker Management
    func addTracker(_ tracker: Tracker) {
        try? trackerStore.addTracker(tracker)
    }
    
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        
        if recordStore.isCompleted(tracker, on: date) {
            recordStore.deleteRecord(record)
        } else {
            recordStore.addRecord(record)
        }
        
        dateChanged(to: date)
    }
}

extension TrackersPresenter: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        let trackers = store.trackers
        categories = categorize(trackers: trackers)
        dateChanged(to: currentDate)
    }
}

extension TrackersPresenter: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        dateChanged(to: currentDate)
    }
}

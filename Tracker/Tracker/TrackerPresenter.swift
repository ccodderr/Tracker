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
    func togglePin(for tracker: Tracker)
    func editTracker(_ tracker: Tracker)
    func deleteTracker(_ tracker: Tracker)
    func updateTracker(_ tracker: Tracker)
}

// MARK: - Presenter
final class TrackersPresenter: TrackersPresenterProtocol {
    weak var view: (any TrackersViewControllerProtocol)?
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private var currentDate: Date = Date()
    private var pinnedTrackers: [Tracker] = []
    
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
    
    func togglePin(for tracker: Tracker) {
        trackerStore.updatePinState(for: tracker, isPinned: !tracker.isPinned)
        
        let updatedTrackers = trackerStore.trackers
        categories = categorize(trackers: updatedTrackers)
        dateChanged(to: currentDate)
    }
    
    func editTracker(_ tracker: Tracker) {
        view?.presentEditScreen(for: tracker)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        guard let object = try? trackerStore.fetchTrackerCoreData(by: tracker.id) else { return }
        
        trackerStore.delete(object)
    }
    
    func updateTracker(_ tracker: Tracker) {
        try? trackerStore.updateTracker(tracker)
    }

    private func categorize(trackers: [Tracker]) -> [TrackerCategory] {
        var categoriesDict: [String: [Tracker]] = [:]
        var pinned: [Tracker] = []

        for tracker in trackers {
            if tracker.isPinned {
                pinned.append(tracker)
            } else {
                let categoryTitle = tracker.category.title ?? "Без категории"
                categoriesDict[categoryTitle, default: []].append(tracker)
            }
        }

        var categories: [TrackerCategory] = []

        if !pinned.isEmpty {
            categories.append(TrackerCategory(title: "Закреплённые", trackers: pinned))
        }

        for (title, trackers) in categoriesDict {
            categories.append(TrackerCategory(title: title, trackers: trackers))
        }

        return categories
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

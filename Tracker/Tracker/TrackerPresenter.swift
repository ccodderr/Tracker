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
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String)
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool
    func isEditableDate(_ date: Date) -> Bool
}

// MARK: - Presenter
final class TrackersPresenter: TrackersPresenterProtocol {
    
    var view: (any TrackersViewControllerProtocol)?
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    func viewDidLoad() {
        view?.updateTrackers(categories)
    }
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func isEditableDate(_ date: Date) -> Bool {
        date <= Date()
    }
    
    func isTrackerCompleted(_ tracker: Tracker, date: Date) -> Bool {
        completedTrackers.contains(
            TrackerRecord(
                trackerId: tracker.id,
                date: date
            )
        )
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
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        var newCategories = categories
        
        if let index = newCategories.firstIndex(where: { $0.title == categoryTitle }) {
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: newCategories[index].trackers + [tracker])
            newCategories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
        }
        
        categories = newCategories
        dateChanged(to: currentDate)
    }
    
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) {
        let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
        
        if isTrackerCompleted(tracker, date: date),
           let index = completedTrackers.firstIndex(of: trackerRecord) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(trackerRecord)
        }
        
        dateChanged(to: date)
    }
}

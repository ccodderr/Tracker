//
//  LocalizableView.swift
//  Tracker
//
//  Created by Yana Silosieva on 21.04.2025.
//

import Foundation

// MARK: - Localization
extension String.localized {
    enum localized {
        static let emptyStateTitle = NSLocalizedString("empty.state.Title", comment: "Title for the empty state when no trackers are shown")

        static let trackersTitle = NSLocalizedString("tabbar.trackers.title", comment: "Tab bar title for Trackers")
        static let statisticsTitle = NSLocalizedString("tabbar.statistics.title", comment: "Tab bar title for Statistics")
        
        static let onboardingTitle1 = NSLocalizedString("onboarding.title.1", comment: "First onboarding screen title")
        static let onboardingTitle2 = NSLocalizedString("onboarding.title.2", comment: "Second onboarding screen title")
        static let onboardingButtonTitle = NSLocalizedString("onboarding.button.title", comment: "Onboarding continue button")
        
        static let trackerCreationTitle = NSLocalizedString("tracker.creation.title", comment: "Title for tracker creation screen")
        static let trackerTypeHabit = NSLocalizedString("tracker.type.habit", comment: "Tracker type: habit")
        static let trackerTypeIrregularEvent = NSLocalizedString("tracker.type.irregularEvent", comment: "Tracker type: irregular event")
        static let scheduleTitle = NSLocalizedString("tracker.schedule.title", comment: "Title for tracker schedule section")
        static let categoryTitle = NSLocalizedString("tracker.category.title", comment: "Title for tracker category section")
        static let newHabitTitle = NSLocalizedString("tracker.new.habit.title", comment: "New habit")
        static let newIrregularEventTitle = NSLocalizedString("tracker.new.irregularEvent.title", comment: "New Irregular Event")
        static let createTitle = NSLocalizedString("tracker.action.create", comment: "Create tracker action")
        static let cancelTitle = NSLocalizedString("tracker.action.cancel", comment: "Cancel tracker creation")
        static let colorTitle = NSLocalizedString("tracker.color.title", comment: "Color section title")
        static let emojiTitle = NSLocalizedString("tracker.emoji.title", comment: "Emoji section title")
        static let trackerNamePlaceholder = NSLocalizedString("tracker.name.placeholder", comment: "General tracker name placeholder")
        static let doneTitle = NSLocalizedString("action.done", comment: "Action: Done")
        static let deleteTitle = NSLocalizedString("action.delete", comment: "Action: Delete")
        static let editTitle = NSLocalizedString("action.edit", comment: "Action: Edit")
        static let categoryInputPlaceholder = NSLocalizedString("category.input.placeholder", comment: "Placeholder for entering category name")
        static let categoryEditTitle = NSLocalizedString("category.edit.title", comment: "Title for editing category")
        static let newCategoryTitle = NSLocalizedString("category.new.title", comment: "Title for new category")
        static let categoryDeleteConfirmation = NSLocalizedString("category.delete.confirmation", comment: "Delete category confirmation")
        static let categoryAddButton = NSLocalizedString("category.add.button", comment: "Add category button")
        static let categoryEmptyState = NSLocalizedString("category.empty.state.title", comment: "Category empty state description")
        static let searchTitle = NSLocalizedString("search.title", comment: "Title for the search screen or field")
    }
}

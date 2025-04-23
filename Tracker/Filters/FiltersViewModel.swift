//
//  FiltersViewModel.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

import Foundation

protocol FiltersViewModelDelegate: AnyObject {
    func didChangeFilter()
}

final class FiltersViewModel {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let filterKey = "selectedFilterType"
    private var selectedFilterType: FilterType
    
    weak var delegate: FiltersViewModelDelegate?
    
    // MARK: - Initialization
    init() {
        let rawValue = userDefaults.integer(forKey: filterKey)
        selectedFilterType = FilterType(rawValue: rawValue) ?? .allTrackers
    }
    
    // MARK: - Public Methods
    func getSelectedFilterIndex() -> Int {
        return selectedFilterType.rawValue
    }
    
    func getSelectedFilterType() -> FilterType {
        return selectedFilterType
    }
    
    func setSelectedFilterType(_ filterType: FilterType) {
        selectedFilterType = filterType
        userDefaults.set(filterType.rawValue, forKey: filterKey)
        delegate?.didChangeFilter()
    }
    
    func getFilterTitle() -> String {
        return selectedFilterType.title
    }
    
    func isFilterActive() -> Bool {
        return selectedFilterType != .allTrackers
    }
}

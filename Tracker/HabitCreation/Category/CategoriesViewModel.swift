//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import Foundation

final class CategoryListViewModel {
    // MARK: - Properties
    private let categoryStore: CategoryStore
    private var categories: [Category] = []
    private var selectedCategoryIndex: Int?
    
    // MARK: - Bindings
    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((Category?) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(categoryStore: CategoryStore, selectedCategoryId: UUID?) {
        self.categoryStore = categoryStore
        loadCategories()
        
        if let id = selectedCategoryId {
            selectedCategoryIndex = categories.firstIndex(where: { $0.id == id })
            onCategoriesUpdated?()
        }
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.fetchCategories()
        onCategoriesUpdated?()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func categoryAt(index: Int) -> Category? {
        guard index < categories.count else { return nil }
        return categories[index]
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategoryIndex = index
        onCategorySelected?(categories[index])
    }
    
    func getSelectedCategoryIndex() -> Int? {
        return selectedCategoryIndex
    }
    
    func addNewCategory(title: String) {
        guard !title.isEmpty else {
            onError?("Category title cannot be empty")
            return
        }
        
        categoryStore.addCategory(title: title)
        loadCategories()
    }
    
    func updateCategory(at index: Int, newTitle: String) {
        guard index < categories.count else { return }
        guard !newTitle.isEmpty else {
            onError?("Category title cannot be empty")
            return
        }
        
        let category = categories[index]
        categoryStore.updateCategory(id: category.id, newTitle: newTitle)
        loadCategories()
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        
        let category = categories[index]
        categoryStore.deleteCategory(id: category.id)
        
        if selectedCategoryIndex == index {
            selectedCategoryIndex = nil
        } else if let selected = selectedCategoryIndex, selected > index {
            selectedCategoryIndex = selected - 1
        }
        
        loadCategories()
    }
    
    func dbCategoryAt(index: Int) -> CategoryCoreData? {
        guard index < categories.count else { return nil }
        let category = categories[index]
        
        return categoryStore.getCategory(with: category.id)
    }
}

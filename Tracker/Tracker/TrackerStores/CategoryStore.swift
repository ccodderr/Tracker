//
//  CategoryStore.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import CoreData

final class CategoryStore {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TCategoryCoreData>
    
    init() {
        context = AppDelegate.persistentContainer.viewContext
        
        let fetchRequest = TCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        try? fetchedResultsController.performFetch()
    }
    
    func fetchCategories() -> [Category] {
        try? fetchedResultsController.performFetch()
        
        guard let results = fetchedResultsController.fetchedObjects
        else { return [] }
        
        return results.map {
            Category(title: $0.title ?? "", id: $0.id ?? UUID())
        }
    }

    func addCategory(title: String) {
        let newCategory = TCategoryCoreData(context: context)
        newCategory.title = title
        newCategory.id = .init()
        
        do {
            try context.save()
            print("Category saved successfully")
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func updateCategory(id: UUID, newTitle: String) {
        guard let object = fetchedResultsController.fetchedObjects?.first(
            where: { $0.id == id }
        ) else { return }
        
        object.title = newTitle
        
        do {
            try context.save()
            print("Category updated successfully")
        } catch {
            print("Update error: \(error)")
        }
    }
    
    func deleteCategory(id: UUID) {
        guard let object = fetchedResultsController.fetchedObjects?.first(
            where: { $0.id == id }
        ) else { return }
        
        context.delete(object)
        
        do {
            try context.save()
            print("Category deleted successfully")
        } catch {
            print("Delete error: \(error)")
        }
    }
}

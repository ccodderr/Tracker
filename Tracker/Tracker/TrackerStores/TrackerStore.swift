//
//  TrackerStore.swift
//  Tracker
//
//  Created by Yana Silosieva on 14.04.2025.
//

import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
    
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
}

protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    override init() {
        context = AppDelegate.persistentContainer.viewContext
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    var trackers: [Tracker] {
        fetchedResultsController.fetchedObjects?.compactMap { self.tracker(from: $0) } ?? []
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let trackerData = TrackerCoreData(context: context)
        update(trackerData, from: tracker)
        try context.save()
    }
    
    private func update(_ trackerData: TrackerCoreData, from tracker: Tracker) {
        trackerData.id = tracker.id
        trackerData.title = tracker.title
        trackerData.emoji = tracker.emoji
        trackerData.explictDate = tracker.explicitDate
        trackerData.color = tracker.color
        trackerData.schedule = tracker.schedule as NSObject
        trackerData.category = tracker.category
    }
    
    private func tracker(from data: TrackerCoreData) -> Tracker? {
        guard
            let id = data.id,
            let title = data.title,
            let emoji = data.emoji,
            let color = data.color,
            let schedule = data.schedule as? [Weekdays],
            let category = data.category
        else { return nil }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            explicitDate: data.explictDate,
            category: category
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes,
            let movedIndexes = movedIndexes
        else { return }
        
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes,
                movedIndexes: movedIndexes
            )
        )
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            insertedIndexes?.insert(newIndexPath.item)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes?.insert(indexPath.item)
            
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes?.insert(indexPath.item)
            
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
            
        @unknown default:
            break
        }
    }
}

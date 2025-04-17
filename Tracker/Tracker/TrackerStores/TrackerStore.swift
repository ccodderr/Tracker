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
    }
    
    private func tracker(from data: TrackerCoreData) -> Tracker? {
        guard
            let id = data.id,
            let title = data.title,
            let emoji = data.emoji,
            let color = data.color,
            let schedule = data.schedule as? [Weekdays]
        else { return nil }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            explicitDate: data.explictDate
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
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert: insertedIndexes?.insert(newIndexPath!.item)
        case .delete: deletedIndexes?.insert(indexPath!.item)
        case .update: updatedIndexes?.insert(indexPath!.item)
        case .move:
            movedIndexes?.insert(.init(oldIndex: indexPath!.item, newIndex: newIndexPath!.item))
        @unknown default: break
        }
    }
}

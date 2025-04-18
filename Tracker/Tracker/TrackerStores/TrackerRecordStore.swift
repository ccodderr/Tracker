//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Yana Silosieva on 14.04.2025.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: [TrackerRecord] {
        fetchedResultsController.fetchedObjects?.compactMap { record in
            guard let trackerId = record.trackerId,
                  let date = record.date
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        } ?? []
    }
    
    override init() {
        context = AppDelegate.persistentContainer.viewContext
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to perform fetch for TrackerRecordCoreData: \(error.localizedDescription)")
        }
    }
    
    func addRecord(_ record: TrackerRecord) {
        guard !records.contains(record) else { return }
        
        let coreDataRecord = TrackerRecordCoreData(context: context)
        coreDataRecord.trackerId = record.trackerId
        coreDataRecord.date = record.date
        try? context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        guard let object = fetchedResultsController.fetchedObjects?.first(where: {
            $0.trackerId == record.trackerId &&
            Calendar.current.isDate($0.date ?? .distantPast, inSameDayAs: record.date)
        }) else { return }
        
        context.delete(object)
        try? context.save()
    }
    
    func getCountOf(_ tracker: Tracker) -> Int {
        let count = fetchedResultsController.fetchedObjects?.filter {
            $0.trackerId == tracker.id
        }.count
        
        return count ?? .zero
    }
    
    func isCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        records.contains(TrackerRecord(trackerId: tracker.id, date: date))
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.didUpdateRecords()
    }
}

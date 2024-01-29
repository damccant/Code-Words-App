//
//  DataManager.swift
//  ClassProject
//
//  Created by Derek McCants on 10/21/23.
//

import Foundation
import CoreData
import OrderedCollections

class DataManager: NSObject, ObservableObject {
    enum DataManagerType {
        case normal, preview, testing
    }
    
    static let shared = DataManager(type: .normal)
    static let preview = DataManager(type: .preview)
    static let testing = DataManager(type: .testing)
    
    @Published var locations: OrderedDictionary<UUID, SavedLocation> = [:]
    
    var locationArray: [SavedLocation] {
        Array(locations.values)
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let locationFRC: NSFetchedResultsController<SavedLocationItem>
    
    private init(type: DataManagerType) {
        switch type {
        case .normal:
            let persistentStore = PersistenceController()
            self.managedObjectContext = persistentStore.context
        case .preview:
            let persistentStore = PersistenceController(inMemory: true)
            self.managedObjectContext = persistentStore.context
            // Add Mock Data
            try? self.managedObjectContext.save()
        case .testing:
            let persistentStore = PersistenceController(inMemory: true)
            self.managedObjectContext = persistentStore.context
        }
        
        let todoFR: NSFetchRequest<SavedLocationItem> = SavedLocationItem.fetchRequest()
        todoFR.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        locationFRC = NSFetchedResultsController(fetchRequest: todoFR,
                                              managedObjectContext: managedObjectContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        
        super.init()
        
        // Initial fetch to populate todos array
        locationFRC.delegate = self
        try? locationFRC.performFetch()
        // ------------------------------
        // TODO: fix these cryptic errors
        // ------------------------------
        /*if let newLocations = locationFRC.fetchedObjects {
            self.locations = OrderedDictionary(uniqueKeysWithValues: newLocations.map({ ($0.id, SavedLocation(managed: $0)) }))
        }*/
    }
    
    func saveData() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
}

extension DataManager: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // ------------------------------
        // TODO: fix these cryptic errors
        // ------------------------------
        /*if let newLocations = controller.fetchedObjects as? [SavedLocationItem] {
            self.locations = OrderedDictionary(uniqueKeysWithValues: newLocations.map({ ($0.id, SavedLocation(managed: $0)) }))
        }*/
    }
}

extension SavedLocation {
    fileprivate convenience init(managed: SavedLocationItem) {
        self.init(longitude: managed.longitude, latitude: managed.latitude)
    }
}

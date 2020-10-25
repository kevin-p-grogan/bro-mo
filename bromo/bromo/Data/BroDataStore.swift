//
//  File.swift
//  bromo
//
//  Created by Kevin Grogan on 10/25/20.
//

import Foundation
import CoreData

public class BroDataStore {
    // MARK: - Define Constants / Variables
    public static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // MARK: - Initializer
    private init() {}
    // MARK: - Core Data stack
    public static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BroDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true  // automatic merging of changes saved from parent context or persistent store
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy  // in-memory trumps external changes
        return container
    }()
    // MARK: - Core Data Saving support
    public static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

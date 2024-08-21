//
//  LocationLogger.swift
//  BackgroundLocationDemo
//
//  Created by Shashi Gupta on 21/08/24.
//

import CoreData
import CoreLocation

protocol LocationLoggerProtocol{
    func logLocation(_ location: CLLocation, sentToServer: Bool) // Make entry of log
    func analyzeLogs() // Call this method to log all logs in console
    func fetchLogs() -> [LocationLog] // fetch all logs
    func removeAllLogs() // Remove/Clear all log from DB
    func removeLogs(olderThan date: Date) /* Remove logs older than a specific date
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    locationLogger.removeLogs(olderThan: cutoffDate)*/
}

class LocationLogger : LocationLoggerProtocol{
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "xcdatamodeld")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        context = persistentContainer.viewContext
    }
    
    func logLocation(_ location: CLLocation, sentToServer: Bool) {
        let log = LocationLog(context: context)
        log.timestamp = Date()
        log.latitude = location.coordinate.latitude
        log.longitude = location.coordinate.longitude
        log.status = sentToServer ? "Sent" : "Failed"
        
        saveContext()
    }
    
    func fetchLogs() -> [LocationLog] {
        let fetchRequest: NSFetchRequest<LocationLog> = LocationLog.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch logs: \(error)")
            return []
        }
    }
    
    func analyzeLogs() {
        let logs = fetchLogs()
        for log in logs {
            print("Timestamp: \((log.timestamp ?? Date()).toLocalTimeString()), Latitude: \(log.latitude), Longitude: \(log.longitude), Status: \(log.status ?? "Unknown")")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func removeAllLogs() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LocationLog.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            print("All logs have been removed.")
        } catch {
            print("Failed to remove logs: \(error)")
        }
    }
    
    func removeLogs(olderThan date: Date) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LocationLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", date as NSDate)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            print("Logs older than \(date.toLocalTimeString()) have been removed.")
        } catch {
            print("Failed to remove logs: \(error)")
        }
    }
}

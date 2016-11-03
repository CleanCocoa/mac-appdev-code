import Cocoa
import CoreData

public let kDefaultModelName: String = "DDDViewDataExample"

open class PersistentStack: NSObject {
    
    let storeType = NSSQLiteStoreType
    let storeURL:URL
    let modelURL:URL

    open var managedObjectContext: NSManagedObjectContext?
    
    // TODO forbid init()
    
    public init(storeURL:URL, modelURL:URL) {
        self.storeURL = storeURL
        self.modelURL = modelURL
        
        super.init()
        
        self.setupManagedObjectContext()
    }
    
    func setupManagedObjectContext() {
        guard let coordinator = self.persistentStoreCoordinator else {
            return
        }
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        self.managedObjectContext = managedObjectContext
    }
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: kDefaultModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        
        // Create the coordinator and store
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let store: NSPersistentStore
        
        do {
            store = try coordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: self.storeURL, options: self.defaultStoreOptions())
        } catch var underlyingError as NSError {
            
            var dict = [AnyHashable: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = underlyingError
            
            let error = NSError(domain: kErrorDomain, code: 9999, userInfo: dict)
            NSApplication.shared().presentError(error)
            
            return nil
        } catch {
            fatalError("Could not create perstistentStoreCoordinator")
        }
        
        return coordinator
    }()
    
    
    // MARK: - Core Data Saving and Undo support
    
    open func objectContextWillSave() {
        // TODO: update creation/modification dates
    }
    
    open func save() {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        guard let managedObjectContext = self.managedObjectContext else {
            return
        }
        
        guard managedObjectContext.commitEditing() else {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
            return
        }
        
        guard managedObjectContext.hasChanges else {
            return
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSApplication.shared().presentError(error)
        
            NSLog("Failed to save to data store: \(error.localizedDescription)")
            logDetailledErrors(error)
        }
    }
    
    open func undoManager() -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        guard let managedObjectContext = self.managedObjectContext else {
            return nil
        }
        
        return managedObjectContext.undoManager
    }
    
    open func defaultStoreOptions() -> [String: AnyObject] {
        return [
            NSMigratePersistentStoresAutomaticallyOption: true as AnyObject,
            NSInferMappingModelAutomaticallyOption: true as AnyObject
        ]
    }
    
    /// Save changes in the application's managed object context before the application terminates.
    open func saveToTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        guard let managedObjectContext = self.managedObjectContext else {
            return .terminateNow
        }
        
        guard managedObjectContext.commitEditing() else {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        guard managedObjectContext.hasChanges else {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            
            NSLog("Failed to save to data store: \(error.localizedDescription)")
            logDetailledErrors(error)
                        
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info")
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .terminateCancel
            }
        }
        
        return .terminateNow
    }
}

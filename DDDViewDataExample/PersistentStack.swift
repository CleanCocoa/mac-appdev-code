import Cocoa
import CoreData

public let kDefaultModelName: String = "DDDViewDataExample"

public class PersistentStack: NSObject {
    let storeType = NSSQLiteStoreType
    let storeURL:NSURL
    let modelURL:NSURL

    public var managedObjectContext: NSManagedObjectContext?
    
    // TODO forbid init()
    
    public init(storeURL:NSURL, modelURL:NSURL) {
        self.storeURL = storeURL
        self.modelURL = modelURL
        
        super.init()
        
        self.setupManagedObjectContext()
    }
    
    func setupManagedObjectContext() {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return
        }
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        self.managedObjectContext = managedObjectContext
    }
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(kDefaultModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeOptions = self.defaultStoreOptions()
        let store: NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: self.storeURL, options: storeOptions)
        } catch var error1 as NSError {
            error = error1
            store = nil
        } catch {
            fatalError()
        }
        
        if store == nil {
            var dict = [NSObject : AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: kErrorDomain, code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        }
        
        return coordinator
    }()
    
    
    // MARK: - Core Data Saving and Undo support
    
    public func objectContextWillSave() {
        // TODO: update creation/modification dates
    }
    
    public func save() {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSApplication.sharedApplication().presentError(error!)
                
                    NSLog("Failed to save to data store: \(error!.localizedDescription)")
                    logDetailledErrors(error!)
                }
            }
        }
    }
    
    public func undoManager() -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        }
        return nil
    }
    
    public func defaultStoreOptions() -> Dictionary<String, String> {
        let opts = Dictionary<String, String>()
        return opts
    }
    
    /// Save changes in the application's managed object context before the application terminates.
    public func saveToTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        if managedObjectContext == nil {
            return .TerminateNow
        }
        
        let moc = managedObjectContext!
        
        if !moc.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
            return .TerminateCancel
        }
        
        if !moc.hasChanges {
            return .TerminateNow
        }
        
        var error: NSError? = nil
        do {
            try moc.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("Failed to save to data store: \(error!.localizedDescription)")
            logDetailledErrors(error!)
            
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(error!)
            if (result) {
                return .TerminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .TerminateCancel
            }
        }
        return .TerminateNow
    }
}

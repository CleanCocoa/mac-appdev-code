import Cocoa
import CoreData
import Security

public protocol GeneratesIntegerId {
    func integerId() -> IntegerId
}

let coreDataReadErrorNotificationName = Notification.Name(rawValue: "Core Data Read Error")

open class CoreDataBoxRepository: BoxRepository {
    let managedObjectContext: NSManagedObjectContext
    let integerIdGenerator: GeneratesIntegerId
    
    public convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(managedObjectContext: managedObjectContext, integerIdGenerator: DefaultIntegerIdGenerator())
    }
    
    public init(managedObjectContext: NSManagedObjectContext, integerIdGenerator: GeneratesIntegerId) {
        self.managedObjectContext = managedObjectContext
        self.integerIdGenerator = integerIdGenerator
    }
    
    //MARK: -
    //MARK: CRUD Actions
    
    open func addBox(_ box: Box) {
        ManagedBox.insertManagedBox(box.boxId, title: box.title, inManagedObjectContext: self.managedObjectContext)
    }
    
    open func removeBox(boxId: BoxId) {
        guard let managedBox = managedBoxWithId(boxId) else {
            return
        }
        
        managedObjectContext.delete(managedBox)
    }
    
    open func box(boxId: BoxId) -> Box? {
        guard let managedBox = managedBoxWithId(boxId) else {
            return nil
        }
        
        return managedBox.box
    }
    
    fileprivate func managedBoxWithId(_ boxId: BoxId) -> ManagedBox? {
        return managedBoxWithUniqueId(boxId.identifier)
    }
        
    open func boxes() -> [Box] {
        let fetchRequest = NSFetchRequest<ManagedBox>(entityName: ManagedBox.entityName)
        fetchRequest.includesSubentities = true
        
        let results: [AnyObject]
        
        do {
            results = try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            logError(error, operation: "find existing boxes")
            postReadErrorNotification()
            assertionFailure("error fetching boxes")
            return []
        }

        return results
            .map { $0 as! ManagedBox }
            .map { $0.box }
    }
    
    /// - returns: `NSNotFound` on error
    open func count() -> Int {
        let fetchRequest = NSFetchRequest<ManagedBox>(entityName: ManagedBox.entityName)
        fetchRequest.includesSubentities = false

        let count: Int

        do {
            count = try managedObjectContext.count(for: fetchRequest)
        } catch {
            logError(error, operation: "fetching box count")
            postReadErrorNotification()
            assertionFailure("error fetching count")
            return NSNotFound
        }
        
        return count
    }
    
    
    //MARK: Box ID Generation
    
    open func nextId() -> BoxId {
        func hasManagedBoxWithUniqueId(identifier: IntegerId) -> Bool {
            return self.managedBoxWithUniqueId(identifier) != nil
        }

        let generator = IdGenerator<BoxId>(integerIdGenerator: integerIdGenerator, integerIdIsTaken: hasManagedBoxWithUniqueId)
        return generator.nextId()
    }
    
    fileprivate func managedBoxWithUniqueId(_ identifier: IntegerId) -> ManagedBox? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedBoxWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["IDENTIFIER": NSNumber(value: identifier as Int64)])
        
        precondition(hasValue(fetchRequest), "Fetch request named 'ManagedBoxWithUniqueId' is required")
        
        let result: [AnyObject]

        do {
            result = try managedObjectContext.fetch(fetchRequest!)
        } catch let error as NSError {
            logError(error, operation: "find existing box with ID '\(identifier)'")
            postReadErrorNotification()
            assertionFailure("error fetching box with id")
            return nil
        }

        return result.first as? ManagedBox
    }
    
    
    //MARK: Item ID Generation
    
    open func nextItemId() -> ItemId {
        let generator = IdGenerator<ItemId>(integerIdGenerator: integerIdGenerator, integerIdIsTaken: hasManagedItemWithUniqueId)
        return generator.nextId()
    }
    
    fileprivate func hasManagedItemWithUniqueId(_ identifier: IntegerId) -> Bool {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedItemWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["IDENTIFIER": NSNumber(value: identifier as Int64)])
        
        precondition(hasValue(fetchRequest), "Fetch request named 'ManagedItemWithUniqueId' is required")
        
        let count: Int

        do {
            count = try managedObjectContext.count(for: fetchRequest!)
        } catch {
            logError(error, operation: "find existing item with ID '\(identifier)'")
            postReadErrorNotification()
            assertionFailure("error fetching item with id")
            return false
        }
        
        return count > 0
    }
    
    
    //MARK: -
    //MARK: Error Handling
    
    func logError(_ error: Error, operation: String) {
        NSLog("Failed to \(operation): \(error.localizedDescription)")
        logDetailledErrors(error)
    }

    /// - note: Override-point for error handling in tests.
    open var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    func postReadErrorNotification() {
        notificationCenter.post(name: coreDataReadErrorNotificationName, object: self)
    }
}

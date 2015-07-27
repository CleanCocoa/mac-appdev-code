import Cocoa
import CoreData
import Security

public protocol GeneratesIntegerId {
    func integerId() -> IntegerId
}

struct DefaultIntegerIdGenerator: GeneratesIntegerId {
    func integerId() -> IntegerId {
        arc4random_stir()
        var urandom: UInt64
        urandom = (UInt64(arc4random()) << 32) | UInt64(arc4random())
        
        let random: IntegerId = (IntegerId) (urandom & 0x7FFFFFFFFFFFFFFF)
        
        return random
    }
}

struct IdGenerator<Id: Identifiable> {
    let integerIdGenerator: GeneratesIntegerId
    let integerIdIsTaken: (IntegerId) -> Bool
    
    func nextId() -> Id {
        return Id(unusedIntegerId())
    }

    func unusedIntegerId() -> IntegerId {
        var identifier: IntegerId
        
        repeat {
            identifier = integerId()
        } while integerIdIsTaken(identifier)
        
        return identifier
    }

    func integerId() -> IntegerId {
        return integerIdGenerator.integerId()
    }
}

let kCoreDataReadErrorNotificationName = "Core Data Read Error"

public class CoreDataBoxRepository: NSObject {
    let managedObjectContext: NSManagedObjectContext
    let integerIdGenerator: GeneratesIntegerId
    
    public convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(managedObjectContext: managedObjectContext, integerIdGenerator: DefaultIntegerIdGenerator())
    }
    
    public init(managedObjectContext: NSManagedObjectContext, integerIdGenerator: GeneratesIntegerId) {
        self.managedObjectContext = managedObjectContext
        self.integerIdGenerator = integerIdGenerator
        
        super.init()
    }
}

extension CoreDataBoxRepository: BoxRepository {

    //MARK: -
    //MARK: CRUD Actions
    
    public func addBoxWithId(boxId: BoxId, title: String) {
        Box.insertBoxWithId(boxId, title: title, inManagedObjectContext: self.managedObjectContext)
    }
    
    public func removeBox(boxId boxId: BoxId) {
        guard let box = boxWithId(boxId) as? Box else {
            return
        }
        
        managedObjectContext.deleteObject(box)
    }
    
    public func boxWithId(boxId: BoxId) -> BoxType? {
        return boxWithUniqueId(boxId.identifier)
    }
        
    public func boxes() -> [BoxType] {
        let fetchRequest = NSFetchRequest(entityName: Box.entityName)
        fetchRequest.includesSubentities = true
        
        let results: [AnyObject]
        
        do {
            results = try managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            logError(error, operation: "find existing boxes")
            postReadErrorNotification()
            assertionFailure("error fetching boxes")
            return []
        }
        
        return results.map { $0 as! Box }
    }
    
    /// @returns `NSNotFound` on error
    public func count() -> Int {
        let fetchRequest = NSFetchRequest(entityName: Box.entityName)
        fetchRequest.includesSubentities = false
        
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        
        if count == NSNotFound {
            logError(error!, operation: "fetching box count")
            postReadErrorNotification()
            assertionFailure("error fetching count")
            return NSNotFound
        }
        
        return count
    }
    
    
    //MARK: Box ID Generation
    
    public func nextId() -> BoxId {
        let hasManagedBoxWithUniqueId: (IntegerId) -> Bool = { identifier in
            return self.boxWithUniqueId(identifier) != nil
        }
        let generator = IdGenerator<BoxId>(integerIdGenerator: integerIdGenerator, integerIdIsTaken: hasManagedBoxWithUniqueId)
        return generator.nextId()
    }
    
    func boxWithUniqueId(identifier: IntegerId) -> Box? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedBoxWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName(templateName, substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        precondition(hasValue(fetchRequest), "Fetch request named 'ManagedBoxWithUniqueId' is required")
        
        let result: [AnyObject]

        do {
            result = try managedObjectContext.executeFetchRequest(fetchRequest!)
        } catch let error as NSError {
            logError(error, operation: "find existing box with ID '\(identifier)'")
            postReadErrorNotification()
            assertionFailure("error fetching box with id")
            return nil
        }
        
        if result.count == 0 {
            return nil
        }
        
        return result.first as? Box
    }
    
    
    //MARK: Item ID Generation
    
    public func nextItemId() -> ItemId {
        let generator = IdGenerator<ItemId>(integerIdGenerator: integerIdGenerator, integerIdIsTaken: hasItemWithUniqueId)
        return generator.nextId()
    }
    
    func hasItemWithUniqueId(identifier: IntegerId) -> Bool {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedItemWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName(templateName, substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        precondition(hasValue(fetchRequest), "Fetch request named 'ManagedItemWithUniqueId' is required")
        
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest!, error: &error)
        
        if count == NSNotFound {
            logError(error!, operation: "find existing item with ID '\(identifier)'")
            postReadErrorNotification()
            assertionFailure("error fetching item with id")
            return false
        }
        
        return count > 0
    }
    
    
    //MARK: -
    //MARK: Error Handling
    
    func logError(error: NSError, operation: String) {
        NSLog("Failed to \(operation): \(error.localizedDescription)")
        logDetailledErrors(error)
    }
    
    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    func postReadErrorNotification() {
        notificationCenter.postNotificationName(kCoreDataReadErrorNotificationName, object: self)
    }
}

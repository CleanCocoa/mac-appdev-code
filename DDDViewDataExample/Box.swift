import Foundation
import CoreData

private var boxContext = 0

public protocol BoxType: class {
    var boxId: BoxId { get }
    var title: String { get }
    var items: [ItemType] { get }
    
    func addItemWithId(itemId: ItemId, title: String)
    func item(itemId itemId: ItemId) -> Item?
    func removeItem(itemId itemId: ItemId)
    
    func changeTitle(title: String)
}

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBoxWithId(boxId: BoxId, title: String)
    func removeBox(boxId boxId: BoxId)
    func boxes() -> [BoxType]
    func boxWithId(boxId: BoxId) -> BoxType?
    func count() -> Int
}

@objc(Box)
public class Box: NSManagedObject {

    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var title: String
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var managedItems: NSSet
    
    public class func insertBoxWithId(boxId: BoxId, title: String, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let box = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)as! Box
        
        box.uniqueId = uniqueIdFromBoxId(boxId)
        box.title = title
    }
    
    class func uniqueIdFromBoxId(boxId: BoxId) -> NSNumber {
        return NSNumber(longLong: boxId.identifier)
    }
    
}

extension Box: Entity {
    
    public class func entityName() -> String {
        return "ManagedBox"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
}

extension Box: BoxType {
    
    public var boxId: BoxId {
        return BoxId(uniqueId.longLongValue)
    }
    
    public var items: [ItemType] {
        return managedItems.allObjects.map { $0 as! ItemType }
    }
    
    public func addItemWithId(itemId: ItemId, title: String) {
        
        Item.insertItemWithId(itemId, title: title, intoBox: self, inManagedObjectContext: managedObjectContext!)
    }
    
    public func item(itemId itemId: ItemId) -> Item? {
        return items.filter { $0.itemId == itemId }.first as? Item
    }
    
    public func removeItem(itemId itemId: ItemId) {
        guard let item = self.item(itemId: itemId) else {
            return
        }
        
        let existingItems = self.mutableSetValueForKey("managedItems")
        existingItems.removeObject(item)
    }
    
    public func changeTitle(title: String) {
        self.title = title
    }
}

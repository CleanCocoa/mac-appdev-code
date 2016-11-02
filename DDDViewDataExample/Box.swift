import Foundation
import CoreData

private var boxContext = 0

public protocol BoxType: class {
    var boxId: BoxId { get }
    var title: String { get }
    var items: [ItemType] { get }
    
    func addItemWithId(_ itemId: ItemId, title: String)
    func item(itemId: ItemId) -> ItemType?
    func removeItem(itemId: ItemId)
    
    func changeTitle(_ title: String)
    func changeItemTitle(itemId: ItemId, title: String)
}

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBoxWithId(_ boxId: BoxId, title: String)
    func removeBox(boxId: BoxId)
    func boxes() -> [BoxType]
    func boxWithId(_ boxId: BoxId) -> BoxType?
    func count() -> Int
}

@objc(Box)
open class Box: NSManagedObject {

    @NSManaged open var creationDate: Date
    @NSManaged open var modificationDate: Date
    @NSManaged open var title: String
    @NSManaged open var uniqueId: NSNumber
    @NSManaged open var managedItems: NSSet
    
    open class func insertBoxWithId(_ boxId: BoxId, title: String, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let box = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)as! Box
        
        box.uniqueId = uniqueIdFromBoxId(boxId)
        box.title = title
    }
    
    class func uniqueIdFromBoxId(_ boxId: BoxId) -> NSNumber {
        return NSNumber(value: boxId.identifier as Int64)
    }
}

extension Box: Entity {
    
    public class var entityName: String {
        return "ManagedBox"
    }
    
    public class func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }
}

extension Box: BoxType {
    
    public var boxId: BoxId {
        return BoxId(uniqueId.int64Value)
    }
    
    public var items: [ItemType] {
        return managedItems.allObjects.map { $0 as! ItemType }
    }
    
    public func addItemWithId(_ itemId: ItemId, title: String) {
        
        Item.insertItemWithId(itemId, title: title, intoBox: self, inManagedObjectContext: managedObjectContext!)
    }
    
    public func item(itemId: ItemId) -> ItemType? {
        return items.filter { $0.itemId == itemId }.first
    }
    
    public func removeItem(itemId: ItemId) {
        guard let item = self.item(itemId: itemId) else {
            return
        }
        
        let existingItems = mutableSetValue(forKey: "managedItems")
        existingItems.remove(item)
    }
    
    public func changeTitle(_ title: String) {
        self.title = title
    }
    
    public func changeItemTitle(itemId: ItemId, title: String) {
        guard let item = item(itemId: itemId) else {
            return
        }
        
        item.changeTitle(title)
    }
}

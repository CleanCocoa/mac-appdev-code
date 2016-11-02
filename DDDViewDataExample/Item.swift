import Foundation
import CoreData

private var itemContext = 0

public protocol ItemType: class {
    var title: String { get }
    var itemId: ItemId { get }
    var box: BoxType { get }
    
    func changeTitle(_ title: String)
}

@objc(Item)
open class Item: NSManagedObject {
    
    @NSManaged open var uniqueId: NSNumber
    @NSManaged open var title: String
    @NSManaged open var creationDate: Date
    @NSManaged open var modificationDate: Date
    @NSManaged open var managedBox: Box
    
    open class func insertItemWithId(_ itemId: ItemId, title: String, intoBox box: Box, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let item = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext) as! Item
        
        item.title = title
        item.uniqueId = uniqueIdFromItemId(itemId)
        item.managedBox = box
    }
    
    class func uniqueIdFromItemId(_ itemId: ItemId) -> NSNumber {
        return NSNumber(value: itemId.identifier as Int64)
    }
}

extension Item: ItemType {
    
    public var itemId: ItemId {
        return ItemId(uniqueId.int64Value)
    }
    
    public var box: BoxType {
        return managedBox as BoxType
    }
    
    public func changeTitle(_ title: String) {
        self.title = title
    }
}

extension Item: Entity {
    
    public class var entityName: String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }
}

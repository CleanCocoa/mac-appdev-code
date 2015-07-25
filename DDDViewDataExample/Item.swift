import Foundation
import CoreData

private var itemContext = 0

protocol ItemType {
    var itemId: ItemId { get }
}

@objc(Item)
public class Item: NSManagedObject {
    
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var title: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var box: Box
    
    public class func insertItemWithId(itemId: ItemId, title: String, intoBox box: Box, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let item = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext) as! Item
        
        item.title = title
        item.uniqueId = uniqueIdFromItemId(itemId)
        item.box = box
    }
    
    class func uniqueIdFromItemId(itemId: ItemId) -> NSNumber {
        return NSNumber(longLong: itemId.identifier)
    }
}

extension Item: ItemType {
    
    public var itemId: ItemId {
        return ItemId(uniqueId.longLongValue)
    }
}

extension Item: Entity {
    
    public class func entityName() -> String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
}

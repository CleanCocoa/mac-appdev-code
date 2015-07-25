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
    
    public class func insertManagedItemWithId(itemId: ItemId, title: String, intoBox box: Box, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let managedItem = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext) as! Item
        
        managedItem.title = title
        managedItem.uniqueId = uniqueIdFromItemId(itemId)
        managedItem.box = box
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

extension Item: ManagedEntity {
    
    public class func entityName() -> String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
}

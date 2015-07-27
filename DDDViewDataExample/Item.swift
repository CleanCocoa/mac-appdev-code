import Foundation
import CoreData

private var itemContext = 0

public protocol ItemType: class {
    var title: String { get }
    var itemId: ItemId { get }
    var box: BoxType { get }
    
    func changeTitle(title: String)
}

@objc(Item)
public class Item: NSManagedObject {
    
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var title: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var managedBox: Box
    
    public class func insertItemWithId(itemId: ItemId, title: String, intoBox box: Box, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let item = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as! Item
        
        item.title = title
        item.uniqueId = uniqueIdFromItemId(itemId)
        item.managedBox = box
    }
    
    class func uniqueIdFromItemId(itemId: ItemId) -> NSNumber {
        return NSNumber(longLong: itemId.identifier)
    }
}

extension Item: ItemType {
    
    public var itemId: ItemId {
        return ItemId(uniqueId.longLongValue)
    }
    
    public var box: BoxType {
        return managedBox as BoxType
    }
    
    public func changeTitle(title: String) {
        self.title = title
    }
}

extension Item: Entity {
    
    public class var entityName: String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }
}

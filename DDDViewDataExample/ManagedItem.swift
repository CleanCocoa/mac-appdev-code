//
//  ManagedItem.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedItem)
public class ManagedItem: NSManagedObject {
    
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var title: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var box: ManagedBox

    public class func entityName() -> String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedItem(itemId: ItemId, title: NSString, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let item: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)
        var managedItem: ManagedItem = item as ManagedItem
        
        managedItem.uniqueId = uniqueIdFromItemId(itemId)
        managedItem.title = title
    }
    
    class func uniqueIdFromItemId(itemId: ItemId) -> NSNumber {
        return NSNumber(longLong: itemId.identifier)
    }
    
    public func itemId() -> ItemId {
        return ItemId(self.uniqueId.longLongValue)
    }
}

//
//  ManagedBox.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedBox)
public class ManagedBox: NSManagedObject {

    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var title: String
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var items: NSSet

    public class func entityName() -> String {
        return "ManagedBox"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedBox(boxId: BoxId, title: NSString, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let box: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)
        var managedBox: ManagedBox = box as ManagedBox
        
        managedBox.uniqueId = uniqueIdFromBoxId(boxId)
        managedBox.title = title
    }
    
    class func uniqueIdFromBoxId(boxId: BoxId) -> NSNumber {
        return NSNumber(longLong: boxId.identifier)
    }
    
    public func boxId() -> BoxId {
        return BoxId(uniqueId.longLongValue)
    }

}

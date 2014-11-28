//
//  ManagedBox.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

private var kBoxContext = 0

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
    
    //MARK: -
    //MARK: Box Management
    
    private var _box: Box?
    public lazy var box: Box = {
        
        let box = Box(boxId: self.boxId(), title: self.title)
        box.addObserver(self, forKeyPath: "title", options: .New, context: &kBoxContext)
        
        self._box = box
        return box
    }()
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != &kBoxContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change[NSKeyValueChangeNewKey] as String
        }
    }
    
    deinit {
        if let box = _box {
            box.removeObserver(self, forKeyPath: "title")
        }
    }

}

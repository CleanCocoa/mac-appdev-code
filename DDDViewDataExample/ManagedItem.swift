//
//  ManagedItem.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

private var itemContext = 0

@objc(ManagedItem)
public class ManagedItem: NSManagedObject, ManagedEntity {
    
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
    
    public class func insertManagedItem(item: Item, managedBox: ManagedBox, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let theItem: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)
        var managedItem: ManagedItem = theItem as ManagedItem
        
        managedItem.uniqueId = uniqueIdFromItemId(item.itemId)
        managedItem.title = item.title
        managedItem.setItem(item)
        managedItem.box = managedBox
    }
    
    class func uniqueIdFromItemId(itemId: ItemId) -> NSNumber {
        return NSNumber(longLong: itemId.identifier)
    }
    
    public func itemId() -> ItemId {
        return ItemId(self.uniqueId.longLongValue)
    }
    
    //MARK: -
    //MARK: Item Management
    
    private var _item: Item?
    public lazy var item: Item = {
        
        let item = Item(itemId: self.itemId(), title: self.title)
        item.addObserver(self, forKeyPath: "title", options: .New, context: &itemContext)
        
        self._item = item
        return item
    }()
    
    public func setItem(item: Item) {
        assert(_item == nil, "can be set only before lazy initialization of item")
        _item = item
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != &itemContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change[NSKeyValueChangeNewKey] as String
        }
    }
    
    deinit {
        if let item = _item {
            item.removeObserver(self, forKeyPath: "title")
        }
    }
    
}

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
    
    public class func insertManagedItem(item: Item, managedBox: ManagedBox, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let theItem: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)
        let managedItem: ManagedItem = theItem as! ManagedItem
        
        managedItem.item = item
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
    public var item: Item {
        get {
            if let item = _item {
                return item
            }
            
            let item = Item(itemId: self.itemId(), title: self.title)
            // TODO add back-reference to box
            observe(item)
            
            
            _item = item
            
            return item
        }
        set {
            assert(_item == nil, "can be set only before lazy initialization of item")
            
            let item = newValue
            adapt(item)
            observe(item)
            
            _item = item
        }
    }
    
    func observe(item: Item) {
        item.addObserver(self, forKeyPath: "title", options: .New, context: &itemContext)
    }
    
    func adapt(item: Item) {
        uniqueId = ManagedItem.uniqueIdFromItemId(item.itemId)
        title = item.title
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context != &itemContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change?[NSKeyValueChangeNewKey] as! String
        }
    }
    
    deinit {
        if let item = _item {
            item.removeObserver(self, forKeyPath: "title")
        }
    }
    
}

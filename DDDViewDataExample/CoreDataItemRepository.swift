//
//  CoreDataItemRepository.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import CoreData
import Security

public class CoreDataItemRepository: NSObject, ItemRepository {
    let managedObjectContext: NSManagedObjectContext
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    public func addItem(item: Item) {
        ManagedItem.insertManagedItem(item.itemId, title: item.title, inManagedObjectContext: self.managedObjectContext)
    }
    
    public func items() -> Array<Item> {
        return []
        //TODO: items
    }
    
    public func count() -> UInt {
        return 0
        //TODO: count
    }
    
    public func nextId() -> ItemId {
        return ItemId(self.integerId())
        // TODO nextId
    }
    
    func integerId() -> IntegerId {
        arc4random_stir()
        var urandom: UInt64
        urandom = (UInt64(arc4random()) << 32) | UInt64(arc4random())
        
        var random: IntegerId = (IntegerId) (urandom & 0x7FFFFFFFFFFFFFFF);
        
        return random
    }
}

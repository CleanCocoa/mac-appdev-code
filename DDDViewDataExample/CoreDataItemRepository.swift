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

public protocol GeneratesIntegerId {
    func integerId() -> IntegerId
}

struct DefaultIntegerIdGenerator: GeneratesIntegerId {
    func integerId() -> IntegerId {
        arc4random_stir()
        var urandom: UInt64
        urandom = (UInt64(arc4random()) << 32) | UInt64(arc4random())
        
        var random: IntegerId = (IntegerId) (urandom & 0x7FFFFFFFFFFFFFFF);
        
        return random
    }
}

public class CoreDataItemRepository: NSObject, ItemRepository {
    let managedObjectContext: NSManagedObjectContext
    let integerIdGenerator: GeneratesIntegerId
    
    public convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(managedObjectContext: managedObjectContext, integerIdGenerator: DefaultIntegerIdGenerator())
    }
    
    public init(managedObjectContext: NSManagedObjectContext, integerIdGenerator: GeneratesIntegerId) {
        self.managedObjectContext = managedObjectContext
        self.integerIdGenerator = integerIdGenerator
        
        super.init()
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
        return ItemId(unusedIntegerId())
    }
    
    func unusedIntegerId() -> IntegerId {
        var identifier: IntegerId
        
        do {
            identifier = integerId()
        } while integerIdIsTaken(identifier)
        
        return identifier
    }
    
    func integerId() -> IntegerId {
        return integerIdGenerator.integerId()
    }
    
    func integerIdIsTaken(identifier: IntegerId) -> Bool {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName("ManagedItemWithUniqueId", substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        assert(fetchRequest != nil, "Fetch request named 'ManagedItemWithUniqueId' is required")
        
        var error: NSError? = nil
        let foundIdentifiers = managedObjectContext.executeFetchRequest(fetchRequest!, error:&error);
        
        if (foundIdentifiers == nil)
        {
            //FIXME: handle error: send event to delete project from view and say that changes couldn't be saved
            return false
        }
        
        return foundIdentifiers!.count > 0;
    }
}

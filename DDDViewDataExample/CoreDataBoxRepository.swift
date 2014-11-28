//
//  CoreDataBoxRepository.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class CoreDataBoxRepository: NSObject, BoxRepository {
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
    
    public func addBox(box: Box) {
        ManagedBox.insertManagedBox(box.boxId, title: box.title, inManagedObjectContext: self.managedObjectContext)
    }
    
    public func boxes() -> [Box] {
        let fetchRequest = NSFetchRequest(entityName: ManagedBox.entityName())
        
        var error: NSError? = nil
        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if results == nil {
            assert(false, "error")
            //TODO: handle fetch error
            return []
        }
        
        let managedBoxes: [ManagedBox] = results as [ManagedBox]
        
        return managedBoxes.map({ (managedBox: ManagedBox) -> Box in
            return managedBox.box
        })
    }
    
    public func boxWithId(boxId: BoxId) -> Box? {
        if let managedBox = managedBoxWithUniqueId(boxId.identifier) {
            return managedBox.box
        }
        
        return nil
    }
    
    public func count() -> Int {
        let fetchRequest = NSFetchRequest(entityName: ManagedBox.entityName())
        fetchRequest.includesSubentities = false
        
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        
        if count == NSNotFound {
            //FIXME: handle error
            return NSNotFound
        }
        
        return count
    }
    
    public func nextId() -> BoxId {
        let integerId = unusedIntegerId(ManagedBox.self)
        return BoxId(integerId)
    }
    
    public func nextItemId() -> ItemId {
        let integerId = unusedIntegerId(ManagedItem.self)
        return ItemId(integerId)
    }
    
    func unusedIntegerId(type: ManagedEntity.Type) -> IntegerId {
        var identifier: IntegerId
        
        do {
            identifier = integerId(type)
        } while integerIdIsTaken(type, identifier: identifier)
        
        return identifier
    }
    
    func integerId(type: ManagedEntity.Type) -> IntegerId {
        return integerIdGenerator.integerId()
    }
    
    func integerIdIsTaken(type: ManagedEntity.Type, identifier: IntegerId) -> Bool {
        
        if type is ManagedBox.Type {
            return managedBoxWithUniqueId(identifier) != nil
        } else if type is ManagedItem.Type {
            return managedItemWithUniqueId(identifier) != nil
        }
        
        return false
    }
    
    func managedBoxWithUniqueId(identifier: IntegerId) -> ManagedBox? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedBoxWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName(templateName, substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        assert(fetchRequest != nil, "Fetch request named 'ManagedBoxWithUniqueId' is required")
        
        var error: NSError? = nil
        let foundIdentifiers = managedObjectContext.executeFetchRequest(fetchRequest!, error:&error);
        
        if (foundIdentifiers == nil)
        {
            assert(false, "error")
            //FIXME: handle error: send event to delete project from view and say that changes couldn't be saved
            return nil
        }
        
        if foundIdentifiers!.count == 0 {
            return nil
        }
        
        return foundIdentifiers![0] as? ManagedBox
    }
    
    func managedItemWithUniqueId(identifier: IntegerId) -> ManagedItem? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedItemWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName(templateName, substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        assert(fetchRequest != nil, "Fetch request named 'ManagedItemWithUniqueId' is required")
        
        var error: NSError? = nil
        let foundIdentifiers = managedObjectContext.executeFetchRequest(fetchRequest!, error:&error);
        
        if (foundIdentifiers == nil)
        {
            assert(false, "error")
            //FIXME: handle error: send event to delete project from view and say that changes couldn't be saved
            return nil
        }
        
        if foundIdentifiers!.count == 0 {
            return nil
        }
        
        return foundIdentifiers![0] as? ManagedItem
    }
}

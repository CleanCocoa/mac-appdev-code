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
        return []
        //TODO: items
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
        return BoxId(unusedIntegerId())
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
        if let foundBox = managedBoxWithUniqueId(identifier) {
            return true
        }
        
        return false
    }
    
    func managedBoxWithUniqueId(identifier: IntegerId) -> ManagedBox? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName("ManagedBoxWithUniqueId", substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
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
}

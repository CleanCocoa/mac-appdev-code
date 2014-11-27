//
//  ServiceLocator.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class ServiceLocator {
    public class var sharedInstance: ServiceLocator {
        struct Static {
            static let instance: ServiceLocator = ServiceLocator()
        }
        return Static.instance
    }
    
    public class func resetSharedInstance() {
        sharedInstance.reset()
    }
    
    func reset() {
        managedObjectContext = nil
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    public func setManagedObjectContext(managedObjectContext: NSManagedObjectContext) {
        assert(self.managedObjectContext == nil, "managedObjectContext can be set up only once")
        self.managedObjectContext = managedObjectContext
    }
    
    //MARK: Repository Access
    
    public class func boxRepository() -> BoxRepository {
        return sharedInstance.boxRepository()
    }
    
    public func boxRepository() -> BoxRepository {
        assert(managedObjectContext != nil, "managedObjectContext must be set up")
        return CoreDataBoxRepository(managedObjectContext: managedObjectContext!)
    }
}

//
//  ManagedEntity.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 28.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import CoreData

@objc(ManagedEntity)
protocol ManagedEntity: class {
    class func entityName() -> String
    class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}
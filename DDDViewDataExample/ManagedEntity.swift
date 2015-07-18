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
    static func entityName() -> String
    static func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}
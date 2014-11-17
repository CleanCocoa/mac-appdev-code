//
//  CoreDataTestCase.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest
import CoreData

import DDDViewDataExample

class CoreDataTestCase: XCTestCase {
    /// Managed Object Model file name
    var modelName: String?
    
    /// Transiert temporary ManagedObjectContext
    internal lazy var context: NSManagedObjectContext = {
        assert(self.modelName != nil, "modelName required. Call setUp() first")
        
        let modelName: String! = self.modelName
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        let bundle = NSBundle.mainBundle();
        let modelURL = bundle.URLForResource(modelName, withExtension: "momd")
        
        assert(modelURL != nil, "model not loaded")
        let model = NSManagedObjectModel(contentsOfURL: modelURL!)
        let coord = NSPersistentStoreCoordinator(managedObjectModel: model!)
        var error: NSError? = nil
        let store: NSPersistentStore? = coord.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error)
        XCTAssert(store != nil, "store not created: \(error)")
        
        context.persistentStoreCoordinator = coord;
        
        XCTAssertNotNil(context, "Core Data context should have been initialized");
        
        return context
    }()
    
    override func setUp() {
        let modelName:String = kDefaultModelName
        self.setUpWithModelName(modelName)
    }
    
    func setUpWithModelName(modelName: String) {
        super.setUp()
        self.modelName = modelName
    }
}

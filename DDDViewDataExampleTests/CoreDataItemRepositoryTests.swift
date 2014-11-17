//
//  CoreDataItemRepositoryTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class TestIntegerIdGenerator : NSObject, GeneratesIntegerId {
    let firstAttempt: IntegerId = 1234
    let secondAttempt: IntegerId = 5678
    var callCount = 0
    
    func integerId() -> IntegerId {
        let identifier = (callCount == 0 ? firstAttempt : secondAttempt)
        
        callCount++
        
        return identifier
    }
}

class CoreDataItemRepositoryTests: CoreDataTestCase {
    var repository: CoreDataItemRepository?
    
    override func setUp() {
        super.setUp()
        
        repository = CoreDataItemRepository(managedObjectContext: self.context)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }

    //MARK: Adding Entities

    func testAddingProject_InsertsEntityIntoStore() {
        let title = "a title"
        let itemId = repository!.nextId()
        let item = Item(itemId: itemId, title: title)
    
        repository!.addItem(item)

        let items = self.allItems()!
        XCTAssert(items.count > 0, "items expected")
        
        if let managedItem = items.first {
            let thing: ManagedItem = managedItem as ManagedItem
            XCTAssertEqual(managedItem.title, title, "Title should be saved")
            XCTAssertEqual(managedItem.itemId(), itemId, "Item ID should be saved")
        }
    }

    //MARK: Generating IDs
    
    func testNextId_WhenGeneratedIdIsTaken_ReturnsAnotherId() {
        let testGenerator = TestIntegerIdGenerator()
        repository = CoreDataItemRepository(managedObjectContext: self.context, integerIdGenerator: testGenerator)
        let existingId = ItemId(testGenerator.firstAttempt)
        ManagedItem .insertManagedItem(existingId, title: "irrelevant", inManagedObjectContext: self.context)
        
        let itemId = repository!.nextId()
        
        let expectedNextId = ItemId(testGenerator.secondAttempt)
        XCTAssertEqual(itemId, expectedNextId, "Should generate another ID because first one is taken")
    }
}

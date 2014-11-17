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

class CoreDataItemRepositoryTests: CoreDataTestCase {
    var repository: CoreDataItemRepository?
    
    override func setUp() {
        super.setUp()
        
        self.repository = CoreDataItemRepository(managedObjectContext: self.context)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return self.context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }

    //MARK: Adding Entities

    func testAddingProject_InsertsEntityIntoStore() {
        let title = "a title"
        let itemId = repository!.nextId()
        let item = Item(itemId: itemId, title: title)
    
        self.repository!.addItem(item)

        let items = self.allItems()!
        XCTAssert(items.count > 0, "items expected")
        
        if let managedItem = items.first {
            let thing: ManagedItem = managedItem as ManagedItem
            XCTAssertEqual(managedItem.title, title, "Title should be saved")
            XCTAssertEqual(managedItem.itemId(), itemId, "Item ID should be saved")
        }
    }

}

//
//- (void)testNextId_FirstCall_ReturnsProjectId {
//    CTWProjectId *projectId = [repository nextId];
//    
//    assertThat(projectId, isNot(nilValue()));
//    }
//    
//    - (void)testNextId_WhenGeneratedIdIsTaken_ReturnsNewId {
//        repository = [[TestRepository alloc] initWithManagedObjectContext:self.context];
//        CTWProjectId *existingId = [CTWProjectId projectIdWithIntegerId:[(TestRepository *)repository firstAttempt]];
//        [CTWManagedProject insertManagedProjectWithProjectId:existingId title:@"irrelevant" inManagedObjectContext:self.context];
//        
//        CTWProjectId *projectId = [repository nextId];
//        
//        CTWProjectId *expectedNextId = [CTWProjectId projectIdWithIntegerId:[(TestRepository *)repository secondAttempt]];
//        assertThat(projectId, equalTo(expectedNextId));
//    }
//    
//
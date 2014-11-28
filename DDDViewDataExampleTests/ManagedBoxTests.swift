//
//  ManagedBoxTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 27.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class ManagedBoxTests: CoreDataTestCase {
    var repository: CoreDataBoxRepository?
    
    override func setUp() {
        super.setUp()
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func allBoxes() -> [ManagedBox]? {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedBox]?
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }

    func testChangingFetchedBoxTitle_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "before", inManagedObjectContext: context)
        
        if let box = repository!.boxWithId(boxId) {
            box.title = "new title"

            let foundBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "new title")
        } else {
            XCTFail("box not found")
        }
    }
    
    func testAddingItemToFetchedBox_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "irrelevant", inManagedObjectContext: context)
        
        if let box = repository!.boxWithId(boxId) {
            let itemId = ItemId(6789)
            let item = Item(itemId: itemId, title: "the item")
            box.addItem(item)
            
            let foundBox = allBoxes()!.first! as ManagedBox
            let items = foundBox.items
            XCTAssertEqual(items.count, 1, "contains item")
            if let foundItem = items.anyObject() as? ManagedItem {
                XCTAssertEqual(foundItem.item, item)
            } else {
                XCTFail("no item")
            }
            
        } else {
            XCTFail("box not found")
        }
    }

}

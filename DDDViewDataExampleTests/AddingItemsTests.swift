//
//  AddingItemsTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class AddingItemsTests: CoreDataTestCase {
    var boxRepository: BoxRepository?
    var viewController: ItemViewController?
    var eventHandler: BoxAndItemService?

    override func setUp() {
        super.setUp()
        
        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
        
        boxRepository = ServiceLocator.boxRepository()
        eventHandler = BoxAndItemService()

        let windowController = ItemManagementWindowController()
        windowController.loadWindow()
        windowController.eventHandler = eventHandler
        viewController = windowController.itemViewController
    }
    
    override func tearDown() {
        ServiceLocator.resetSharedInstance()
        super.tearDown()
    }
    
    func allBoxes() -> [ManagedBox] {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        let results: [AnyObject]? = context.executeFetchRequest(request, error: nil)
        
        if let boxes = results as? [ManagedBox] {
            return boxes
        }
        
        return []
    }

    func testAddFirstBox_CreatesBoxRecord() {
        // Precondition
        XCTAssertEqual(boxRepository!.count(), 0, "repo starts empty")
        
        // When
        viewController!.addBox(self)
    
        // Then
        XCTAssertEqual(boxRepository!.count(), 1, "stores box record")
        
        if let box: ManagedBox = allBoxes().first {
            XCTAssertEqual(box.title, "New Box")
        } else {
            XCTFail("no boxes found")
        }
    }

    func testAddItem_WithBoxInRepo_CreatesItemBelowBox() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "irrelevant", inManagedObjectContext: context)
        XCTAssertEqual(boxRepository!.count(), 1, "repo contains a box")
        
        // When
        viewController!.addItem(self)
        
        // Then
        if let box: ManagedBox = allBoxes().first {
            XCTAssertEqual(box.items.count, 1, "contains an item")
            
            if let item: ManagedItem = box.items.anyObject() as? ManagedItem {
                XCTAssertEqual(item.title, "New Item")
                XCTAssertEqual(item.box, box)
            }
        } else {
            XCTFail("no boxes found")
        }
    }
}

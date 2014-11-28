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
    var useCase: ManageBoxesAndItems! = ManageBoxesAndItems()
    lazy var viewController: ItemViewController = {
        return self.useCase.itemViewController
    }()

    override func setUp() {
        super.setUp()
        
        ServiceLocator.resetSharedInstance()
        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
        
        boxRepository = ServiceLocator.boxRepository()
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
        useCase.showBoxManagementWindow()
        XCTAssertEqual(boxRepository!.count(), 0, "repo starts empty")
        
        // When
        viewController.addBox(self)
    
        // Then
        XCTAssertEqual(boxRepository!.count(), 1, "stores box record")
        
        if let box: ManagedBox = allBoxes().first {
            XCTAssertEqual(box.title, "New Box")
        } else {
            XCTFail("no boxes found")
        }
    }
    
    func testExistingBoxes_ShowInView() {
        let existingId = BoxId(678)
        let existingTitle = "a title"
        ManagedBox.insertManagedBox(existingId, title: existingTitle, inManagedObjectContext: context)
        
        useCase.showBoxManagementWindow()
        
        let boxNodes = viewController.itemsController.arrangedObjects.childNodes!!
        XCTAssertEqual(boxNodes.count, 1)
        let boxNode = boxNodes[0].representedObject as BoxNode
        XCTAssertEqual(boxNode.boxId, existingId)
        XCTAssertEqual(boxNode.title, existingTitle)
    }

    func testAddItem_WithBoxInRepo_CreatesItemBelowBox() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "irrelevant", inManagedObjectContext: context)
        useCase.showBoxManagementWindow()
        
        // When
        viewController.addItem(self)
        
        // Then
        if let managedBox: ManagedBox = allBoxes().first {
            if let managedItem: ManagedItem = managedBox.items.anyObject() as? ManagedItem {
                XCTAssertEqual(managedItem.title, "New Item")
                XCTAssertEqual(managedItem.box, managedBox)
            } else {
                XCTFail("no items found")
            }
        } else {
            XCTFail("no boxes found")
        }
    }
}

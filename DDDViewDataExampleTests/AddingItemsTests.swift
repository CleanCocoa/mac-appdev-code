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
    var repository: BoxRepository?
    var viewController: ItemViewController?
    
    override func setUp() {
        super.setUp()
        
        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
        
        repository = ServiceLocator.boxRepository()
        
        let windowController = ItemManagementWindowController(windowNibName: kItemManagementWindowNibName)
        windowController.loadWindow()
        viewController = windowController.itemViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        XCTAssertEqual(repository!.count(), 0, "repo starts empty")
        
        // When
        viewController!.addBox(self)
    
        // Then
        XCTAssertEqual(repository!.count(), 1, "stores box record")
        
        if let box: ManagedBox = allBoxes().first {
            XCTAssertEqual(box.title, "New Box")
        } else {
            XCTFail("no boxes found")
        }
    }

}

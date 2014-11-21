//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class ItemViewControllerTests: XCTestCase {
    var viewController: ItemViewController!
    
    override func setUp() {
        super.setUp()
        
        let windowController = ItemManagementWindowController(windowNibName: kItemManagementWindowNibName)
        windowController.loadWindow()//performSelectorOnMainThread("loadView", withObject: nil, waitUntilDone: true)
        viewController = windowController.itemViewController
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func itemNodes() -> [AnyObject] {
        let arrangedObjects: AnyObject! = viewController.itemsController.arrangedObjects
        return arrangedObjects.childNodes!!;
    }
    
    func itemNodeCount() -> Int {
        return itemNodes().count
    }
//
//    - (id)projectAtIndex:(NSUInteger)index
//    {
//    return [[self projectNodes] objectAtIndex:index];
//    }
//    
//    - (id)nodeAtProjectIndex:(NSUInteger)projectIndex pathIndex:(NSUInteger)pathIndex
//    {
//    return [[[[self projectNodes] objectAtIndex:projectIndex] childNodes] objectAtIndex:pathIndex];
//    }
    
    
    //MARK: Nib Setup
    
    func testView_IsLoaded() {
        XCTAssertNotNil(viewController.view, "view should be set in Nib")
        XCTAssertEqual(viewController.view.className, "NSOutlineView", "view should be table view")
        XCTAssertEqual(viewController.view, viewController.outlineView, "tableView should be alternative to view")
    }

    func testOutlineViewColumns_NamedProperly() {
        let outlineView = viewController.outlineView
        
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kTitleColumnName), "outline should include title column")
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kCountColumnName), "outline should include count column")
    }
    
    func testItemsController_IsConnected() {
        XCTAssertNotNil(viewController.itemsController, "items controller should be connected in Nib")
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.itemsController
        let outlineView = viewController.outlineView
        let titleColumn = outlineView.tableColumnWithIdentifier(kTitleColumnName)
        let countColumn = outlineView.tableColumnWithIdentifier(kCountColumnName)
        
        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"), "items controller should obtain sortDescriptors from view controller through bindings")
        XCTAssertTrue(hasBinding(outlineView, binding: NSContentBinding, to: controller, throughKeyPath: "arrangedObjects"), "outline view should have binding to items controller's arrangedObjects")
        
        XCTAssertTrue(hasBinding(titleColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.title"), "bind title column to title property")
        XCTAssertTrue(hasBinding(countColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.count"), "bind count column to count property")
    }
    
    func testAddItemButton_IsConnected() {
        XCTAssertNotNil(viewController.addItemButton, "add item button not connected")
    }
    
    func testAddItemButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addItemButton.action, Selector("addItem:"), "'add item' button should be wired to addItem:");
    }
    
    //MARK: Adding Item

    func testInitially_TreeIsEmpty() {
        XCTAssertEqual(itemNodeCount(), 0, "start with empty tree")
    }
    
    func testAddingItem_WithEmptyList_AddsItem() {
        viewController.addItem(self)
        
        XCTAssertEqual(itemNodeCount(), 1, "adds item to tree")
    }
    
    
}

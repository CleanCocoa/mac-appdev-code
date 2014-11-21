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

class TestNode: NSObject {
    dynamic var title: String = "title"
    dynamic var count: UInt = 1234
    dynamic var children: [TestNode] = []
    dynamic var isLeaf: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}

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
        return arrangedObjects.childNodes!!
    }
    
    func itemNodeCount() -> Int {
        return itemNodes().count
    }
    
    func itemAtIndex(index: Int) -> AnyObject {
        return itemNodes()[index]
    }
    
    
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
    
    func testItemRowView_TitleCell_SetUpProperly() {
        viewController.itemsController.addObject(TestNode())
        
        let titleCellView: NSTableCellView = viewController.outlineView.viewAtColumn(0, row: 0, makeIfNecessary: true) as NSTableCellView
        let titleTextField = titleCellView.textField!
        XCTAssertTrue(titleTextField.editable, "title text field should be editable")
        XCTAssertTrue(hasBinding(titleTextField, binding: NSValueBinding, to: titleCellView, throughKeyPath: "objectValue.title"), "title text field should modify item title")
    }
    
    func testItemRowView_CountCell_SetUpProperly() {
        viewController.itemsController.addObject(TestNode())
        
        let countCellView: NSTableCellView = viewController.outlineView.viewAtColumn(1, row: 0, makeIfNecessary: true) as NSTableCellView
        let countTextField = countCellView.textField!
        XCTAssertFalse(countTextField.editable, "count text field should not be editable")
        XCTAssertTrue(hasBinding(countTextField, binding: NSValueBinding, to: countCellView, throughKeyPath: "objectValue.count"), "count text field should modify item count")
    }
    
    
    //MARK: - Adding Item

    func testInitially_TreeIsEmpty() {
        XCTAssertEqual(itemNodeCount(), 0, "start with empty tree")
    }
    
    func testAddItem_WithEmptyList_AddsItem() {
        viewController.addItem(self)
        
        XCTAssertEqual(itemNodeCount(), 1, "adds item to tree")
    }
    
    func testAddItem_WithExistingItem_OrdersThemByTitle() {
        // Given
        let bottomItem = TestNode(title: "ZZZ Should be at the bottom")
        viewController.itemsController.addObject(bottomItem)
        
        let existingNode: NSObject = itemAtIndex(0) as NSObject
        
        // When
        viewController.addItem(self)
        
        // Then
        XCTAssertEqual(itemNodeCount(), 2, "add node to existing one")
        let lastNode: NSObject = itemAtIndex(1) as NSObject
        XCTAssertEqual(existingNode, lastNode, "new node should be put before existing one")
    }
    
}

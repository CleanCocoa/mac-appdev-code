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

class TestNode: NSObject, TreeNode {
    dynamic var title: String = "title"
    dynamic var count: UInt = 1234
    dynamic var children: [TreeNode] = []
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
    
    func boxNodes() -> [AnyObject] {
        let arrangedObjects: AnyObject! = viewController.itemsController.arrangedObjects
        return arrangedObjects.childNodes!!
    }
    
    func boxNodeCount() -> Int {
        return boxNodes().count
    }
    
    func boxAtIndex(index: Int) -> NSTreeNode {
        return boxNodes()[index] as NSTreeNode
    }
    
    func itemTreeNode(atBoxIndex boxIndex: Int, itemIndex: Int) -> NSTreeNode {
        let boxNode: NSTreeNode = boxAtIndex(boxIndex)
        return boxNode.childNodes![itemIndex] as NSTreeNode
    }
    
    
    //MARK: Nib Setup
    
    func testView_IsLoaded() {
        XCTAssertNotNil(viewController.view, "view should be set in Nib")
        XCTAssertEqual(viewController.view.className, "NSOutlineView", "view should be table view")
        XCTAssertEqual(viewController.view, viewController.outlineView, "tableView should be alternative to view")
    }

    func testOutlineViewColumns_NamedProperly() {
        let outlineView = viewController.outlineView
        
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameTitle), "outline should include title column")
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameCount), "outline should include count column")
    }
    
    func testItemsController_IsConnected() {
        XCTAssertNotNil(viewController.itemsController, "items controller should be connected in Nib")
    }
    
    func testItemsController_PreservesSelection() {
        XCTAssertTrue(viewController.itemsController.preservesSelection, "items controller should preserve selections")
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.itemsController
        let outlineView = viewController.outlineView
        let titleColumn = outlineView.tableColumnWithIdentifier(kColumnNameTitle)
        let countColumn = outlineView.tableColumnWithIdentifier(kColumnNameCount)
        
        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"), "items controller should obtain sortDescriptors from view controller through bindings")
        XCTAssertTrue(hasBinding(outlineView, binding: NSContentBinding, to: controller, throughKeyPath: "arrangedObjects"), "outline view should have binding to items controller's arrangedObjects")
        
        XCTAssertTrue(hasBinding(titleColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.title"), "bind title column to title property")
        XCTAssertTrue(hasBinding(countColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.count"), "bind count column to count property")
    }
    
    func testAddBoxButton_IsConnected() {
        XCTAssertNotNil(viewController.addBoxButton, "add item button not connected")
    }
    
    func testAddBoxButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addBoxButton.action, Selector("addBox:"), "'add box' button should be wired to addBox:");
    }
    
    func testAddItemButton_IsConnected() {
        XCTAssertNotNil(viewController.addItemButton, "add item button not connected")
    }
    
    func testAddItemButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addItemButton.action, Selector("addItem:"), "'add item' button should be wired to addItem:");
    }
    
    func testAddItemButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.addItemButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
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
    
    
    //MARK: - 
    //MARK: Adding Boxes

    func testInitially_TreeIsEmpty() {
        XCTAssertEqual(boxNodeCount(), 0, "start with empty tree")
    }
    
    func testInitially_AddItemButtonIsDisabled() {
        XCTAssertFalse(viewController.addItemButton.enabled, "disable item button without boxes")
    }
    
    func testAddBox_WithEmptyList_AddsNode() {
        viewController.addBox(self)
        
        XCTAssertEqual(boxNodeCount(), 1, "adds item to tree")
    }
    
    func testAddBox_WithEmptyList_EnablesAddItemButton() {
        viewController.addBox(self)
        
        XCTAssertTrue(viewController.addItemButton.enabled, "enable item button by adding boxes")
    }
    
    func testAddBox_WithExistingBox_OrdersThemByTitle() {
        // Given
        let bottomItem = TestNode(title: "ZZZ Should be at the bottom")
        viewController.itemsController.addObject(bottomItem)
        
        let existingNode: NSObject = boxAtIndex(0)
        
        // When
        viewController.addBox(self)
        
        // Then
        XCTAssertEqual(boxNodeCount(), 2, "add node to existing one")
        let lastNode: NSObject = boxAtIndex(1)
        XCTAssertEqual(existingNode, lastNode, "new node should be put before existing one")
    }

    func testAddBox_Twice_SelectsSecondBox() {
        let treeController = viewController.itemsController
        treeController.addObject(TestNode(title: "first"))
        treeController.addObject(TestNode(title: "second"))
        
        XCTAssertTrue(treeController.selectedNodes.count > 0, "should auto-select")
        let selectedNode: NSTreeNode = treeController.selectedNodes[0] as NSTreeNode
        let item: TreeNode = selectedNode.representedObject as TreeNode
        XCTAssertEqual(item.title, "second", "select latest insertion")
    }
    
    
    //MARK: Adding Items
    
    func testAddItem_WithoutBoxes_DoesNothing() {
        viewController.addItem(self)
        
        XCTAssertEqual(boxNodeCount(), 0, "don't add boxes")
    }
    
    func testAddItem_WithSelectedBox_InsertsItemBelowSelectedBox() {
        // Pre-populate
        let treeController = viewController.itemsController
        treeController.addObject(TestNode(title: "first"))
        treeController.addObject(TestNode(title: "second"))
        
        // Select first node
        let selectionIndexPath = NSIndexPath(index: 0)
        treeController.setSelectionIndexPath(selectionIndexPath)
        let selectedBox = (treeController.selectedNodes[0] as NSTreeNode).representedObject as TreeNode
        XCTAssertEqual(selectedBox.children.count, 0, "box starts empty")
        
        viewController.addItem(self)
        
        // Then
        XCTAssertEqual(selectedBox.children.count, 1, "box contains new child")
        XCTAssertEqual(selectedBox.children[0].isLeaf, true, "child should be item=leaf")
    }

}

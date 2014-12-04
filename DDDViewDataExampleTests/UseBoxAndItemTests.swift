//
//  UseBoxAndItemTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class UseBoxAndItemTests: CoreDataTestCase {
    var boxRepository: BoxRepository?
    var useCase: ManageBoxesAndItems! = ManageBoxesAndItems()
    lazy var viewController: ItemViewController = {
        return self.useCase.itemViewController
    }()

    override func setUp() {
        super.setUp()
        
        DomainEventPublisher.setSharedInstance(DomainEventPublisher(notificationCenter: NSNotificationCenter()))
        
        ServiceLocator.resetSharedInstance()
        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
        
        boxRepository = ServiceLocator.boxRepository()
    }
    
    override func tearDown() {
        ServiceLocator.resetSharedInstance()
        DomainEventPublisher.resetSharedInstance()
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
    
    func allItems() -> [ManagedItem] {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        let results: [AnyObject]? = context.executeFetchRequest(request, error: nil)
        
        if let items = results as? [ManagedItem] {
            return items
        }
        
        return []
    }
    
    func allBoxNodes() -> [NSTreeNode] {
        return viewController.itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
    }
    
    //MARK: -
    //MARK: Add Box

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
        
        let boxNodes = allBoxNodes()
        XCTAssertEqual(boxNodes.count, 1)
        let boxNode = boxNodes[0].representedObject as BoxNode
        XCTAssertEqual(boxNode.boxId, existingId)
        XCTAssertEqual(boxNode.title, existingTitle)
    }

    
    //MARK: Add Item
    
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
    
    func testExistingItems_ShowInView() {
        let existingBoxId = BoxId(123)
        ManagedBox.insertManagedBox(existingBoxId, title: "the box", inManagedObjectContext: context)
        let managedBox = allBoxes().first!
        let existingItemId = ItemId(456)
        let existingItem = Item(itemId: existingItemId, title: "the item")
        ManagedItem.insertManagedItem(existingItem, managedBox: managedBox, inManagedObjectContext: context)
        
        useCase.showBoxManagementWindow()
        
        let boxNodes = allBoxNodes()
        XCTAssertEqual(boxNodes.count, 1)
        let boxNode = boxNodes[0].representedObject as BoxNode
        XCTAssertEqual(boxNode.children.count, 1)
        if let itemNode = boxNode.children.first as? ItemNode {
            XCTAssertEqual(itemNode.itemId, existingItemId)
        } else {
            XCTFail("no item was recreated")
        }
    }
    

    //MARK: -
    //MARK: Edit Box
    
    func testChangeBoxTitle_PersistsChanges() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "old title", inManagedObjectContext: context)
        useCase.showBoxManagementWindow()
        
        let newTitle = "new title"
        changeSoleBox(title: newTitle)
        
        let managedBox = allBoxes().first!
        XCTAssertEqual(managedBox.title, newTitle)
    }
    
    func changeSoleBox(title newTitle: String) {
        let soleBoxTreeNode = allBoxNodes().first!
        let boxNode = soleBoxTreeNode.representedObject as BoxNode
        boxNode.title = newTitle
    }
    
    //MARK: Edit Item
    
    func testChangeItemTitle_PersistsChanges() {
        createBoxWithItem()
        useCase.showBoxManagementWindow()
        
        let newTitle = "new title"
        changeSoleItem(title: newTitle)
        
        let managedBox = allBoxes().first!
        let managedItem = managedBox.items.anyObject()! as ManagedItem
        XCTAssertEqual(managedItem.title, newTitle)
    }
    
    func createBoxWithItem() {
        let existingBoxId = BoxId(123)
        ManagedBox.insertManagedBox(existingBoxId, title: "the box", inManagedObjectContext: context)
        
        let managedBox = allBoxes().first!
        let existingItemId = ItemId(456)
        let existingItem = Item(itemId: existingItemId, title: "old title")
        ManagedItem.insertManagedItem(existingItem, managedBox: managedBox, inManagedObjectContext: context)
    }
    
    func changeSoleItem(title newTitle: String) {
        let soleBoxTreeNode = allBoxNodes().first!
        let boxNode = soleBoxTreeNode.representedObject as BoxNode
        let itemNode = boxNode.children.first! as ItemNode
        itemNode.title = newTitle
    }
    
    
    //MARK: -
    //MARK: Remove Box
    
    func testRemoveBox_PersistsChanged() {
        createBoxWithItem()
        
        useCase.showBoxManagementWindow()
        let itemIndexPath = NSIndexPath(index: 0)
        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
        
        // When
        viewController.removeSelectedObject(self)
        
        // Then
        XCTAssertEqual(allBoxes().count, 0)
        XCTAssertEqual(allItems().count, 0)
    }
    
    //MARK: Remove Item
    
    func testRemoveItem_PersistsChanges() {
        createBoxWithItem()
        let managedBox = allBoxes().first!
        XCTAssertEqual(managedBox.items.count, 1)

        useCase.showBoxManagementWindow()
        let itemIndexPath = NSIndexPath(index: 0).indexPathByAddingIndex(0)
        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
        
        // When
        viewController.removeSelectedObject(self)
        
        // Then
        XCTAssertEqual(managedBox.items.count, 0)
    }
}

//
//  ChangingItemsTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 02/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class ChangingItemsTests: CoreDataTestCase {
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

    func allBoxNodes() -> [NSTreeNode] {
        return viewController.itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
    }

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
}

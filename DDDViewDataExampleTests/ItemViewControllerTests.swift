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
    
    
    //MARK: Nib Setup
    
    func testView_IsLoaded() {
        XCTAssertNotNil(viewController.view, "view should be set in Nib")
        XCTAssertEqual(viewController.view.className, "NSTableView", "view should be table view")
        XCTAssertEqual(viewController.view, viewController.tableView, "tableView should be alternative to view")
    }

    func testItemsController_IsConnected() {
        XCTAssertNotNil(viewController.itemsController, "items controller should be connected in Nib")
    }
    
    func testItemsController_RearrangesObjects() {
        XCTAssertTrue(viewController.itemsController.automaticallyRearrangesObjects, "items controller should rearrange objects")
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.itemsController
        let tableView = viewController.tableView
        
        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"), "items controller should obtain sortDescriptors from view controller through bindings")
        XCTAssertTrue(hasBinding(tableView, binding: NSSelectionIndexesBinding, to: controller, throughKeyPath: "selectionIndexes"), "table view should have binding to items controller's selectionIndexes")
    }
    
}

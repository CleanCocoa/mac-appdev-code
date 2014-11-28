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

    func testChangingFetchedBox_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "before", inManagedObjectContext: context)
        
        if let box = repository!.boxWithId(boxId) {
            box.title = "new title"

            let request = NSFetchRequest(entityName: ManagedBox.entityName())
            let boxes = context.executeFetchRequest(request, error: nil) as [ManagedBox]?
            let foundBox = boxes!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "new title")
        } else {
            XCTFail("box not found")
        }
    }

}

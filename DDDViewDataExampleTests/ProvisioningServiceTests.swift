//
//  ProvisioningServiceTests.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import DDDViewDataExample

class TestBoxRepository: BoxRepository {
    func nextId() -> BoxId {
        return BoxId(0)
    }
    
    func nextItemId() -> ItemId {
        return ItemId(0)
    }
    
    func addBox(box: Box) { }
    func removeBox(boxId boxId: BoxId) { }
    
    func box(boxId boxId: BoxId) -> Box? {
        return nil
    }
    
    func boxes() -> [Box] {
        return []
    }
    
    func count() -> Int {
        return 0
    }
}

class ProvisioningServiceTests: XCTestCase {
    let provisioningService = ProvisioningService(repository: TestBoxRepository())
    let publisher = MockDomainEventPublisher()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }

    func testProvisionBox_PublishesDomainEvent() {
        provisioningService.provisionBox()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }

    func testProvisionItem_PublishesDomainEvent() {
        let box = Box(boxId: BoxId(123), title: "irrelevant")
        provisioningService.provisionItem(inBox: box)
        
        if let event = publisher.lastPublishedEvent as? BoxItemProvisionedEvent {
            XCTAssertEqual(event.boxId, box.boxId)
        } else {
            XCTFail("did not publish event")
        }
    }
}

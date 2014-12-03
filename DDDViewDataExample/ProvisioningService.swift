//
//  ProvisioningService.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

class DomainEventPublisher {
    class func defaultCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
}

let kBoxProvisioned = "Box Provisioned"
let kBoxItemProvisioned = "Box Item Provisioned"

public class ProvisioningService {
    let repository: BoxRepository
    
    var eventPublisher: NSNotificationCenter {
        return DomainEventPublisher.defaultCenter()
    }
    
    init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox() {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, title: "New Box")
        
        repository.addBox(box)
        
        eventPublisher.postNotificationName(kBoxProvisioned,
            object: self,
            userInfo: ["boxId" : NSNumber(longLong: boxId.identifier)])
    }
    
    public func provisionItem(inBox box: Box) {
        let itemId = repository.nextItemId()
        let item = Item(itemId: itemId, title: "New Item")

        box.addItem(item)
        
        let userInfo = ["boxId" : NSNumber(longLong: box.boxId.identifier),
                        "itemId" : NSNumber(longLong: itemId.identifier)]
        eventPublisher.postNotificationName(kBoxItemProvisioned,
            object: self,
            userInfo: userInfo)
    }
}
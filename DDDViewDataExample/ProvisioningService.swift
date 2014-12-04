//
//  ProvisioningService.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public typealias UserInfo = [NSObject : AnyObject]

struct BoxProvisionedEvent: DomainEvent {
    static var eventType: DomainEventType {
        return DomainEventType.BoxProvisioned
    }
    
    let boxId: BoxId
    let title: String
    
    init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    init(userInfo: UserInfo) {
        let boxIdData = userInfo["id"] as NSNumber
        self.boxId = BoxId(boxIdData)
        self.title = userInfo["title"] as String
    }
    
    func userInfo() -> UserInfo {
        // TODO replace NSNumber(...) by using StringLiteralConvertible
        return [
            "id": NSNumber(longLong: boxId.identifier),
            "title": title
        ]
    }
    
    func notification() -> NSNotification {
        return NSNotification(name: BoxProvisionedEvent.eventType.name, object: nil, userInfo: userInfo())
    }
}

struct BoxItemProvisionedEvent: DomainEvent {
    static var eventType: DomainEventType {
        return DomainEventType.BoxItemProvisioned
    }
    
    let boxId: BoxId
    let itemId: ItemId
    let itemTitle: String
    
    init(boxId: BoxId, itemId: ItemId, itemTitle: String) {
        self.boxId = boxId
        self.itemId = itemId
        self.itemTitle = itemTitle
    }
    
    init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as UserInfo
        let boxIdData = boxData["id"] as NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as UserInfo
        let itemIdData = itemData["id"] as NSNumber
        self.itemId = ItemId(itemIdData)
        self.itemTitle = itemData["title"] as String
    }
    
    func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : NSNumber(longLong: boxId.identifier)
            ],
            "item" : [
                "id" : NSNumber(longLong: itemId.identifier),
                "title": itemTitle
            ]
        ]
    }
    
    func notification() -> NSNotification {
        return NSNotification(name: BoxItemProvisionedEvent.eventType.name, object: nil, userInfo: userInfo())
    }
}

public class ProvisioningService {
    let repository: BoxRepository
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox() {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, title: "New Box")
        
        repository.addBox(box)
        
        eventPublisher.publish(BoxProvisionedEvent(boxId: boxId, title: box.title))
    }
    
    public func provisionItem(inBox box: Box) {
        let itemId = repository.nextItemId()
        let item = Item(itemId: itemId, title: "New Item")

        box.addItem(item)
        
        eventPublisher.publish(BoxItemProvisionedEvent(boxId: box.boxId, itemId: itemId, itemTitle: item.title))
    }
}
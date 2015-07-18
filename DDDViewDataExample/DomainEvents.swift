//
//  DomainEvents.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public typealias UserInfo = [NSObject : AnyObject]

public enum DomainEventType: String {
    case BoxProvisioned = "Box Provisioned"
    case BoxItemProvisioned = "Box Item Provisioned"
    
    var name: String {
        return self.rawValue
    }
}

public protocol DomainEvent {
    /// The `DomainEventType` to identify this kind of DomainEvent
    static var eventType: DomainEventType { get }
    
    init(userInfo: UserInfo)
    func userInfo() -> UserInfo
    func notification() -> NSNotification
}

public struct BoxProvisionedEvent: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxProvisioned
    }
    
    public let boxId: BoxId
    public let title: String
    
    public init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    public init(userInfo: UserInfo) {
        let boxIdData = userInfo["id"] as! NSNumber
        self.init(boxId: BoxId(boxIdData), title: userInfo["title"] as! String)
    }
    
    public func userInfo() -> UserInfo {
        // TODO replace NSNumber(...) by using StringLiteralConvertible
        return [
            "id": NSNumber(longLong: boxId.identifier),
            "title": title
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: BoxProvisionedEvent.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxItemProvisionedEvent: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxItemProvisioned
    }
    
    public let boxId: BoxId
    public let itemId: ItemId
    public let itemTitle: String
    
    public init(boxId: BoxId, itemId: ItemId, itemTitle: String) {
        self.boxId = boxId
        self.itemId = itemId
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as! UserInfo
        let itemIdData = itemData["id"] as! NSNumber
        self.itemId = ItemId(itemIdData)
        self.itemTitle = itemData["title"] as! String
    }
    
    public func userInfo() -> UserInfo {
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
    
    public func notification() -> NSNotification {
        return NSNotification(name: BoxItemProvisionedEvent.eventType.name, object: nil, userInfo: userInfo())
    }
}

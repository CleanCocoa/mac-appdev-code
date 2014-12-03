//
//  BoxAndItemService.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 25.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

// App service
public protocol ConsumesBoxAndItem: class {
    func consume(boxData: BoxData)
    func consume(itemData: ItemData)
}

public class BoxAndItemService: HandlesItemListEvents {
    let provisioningService: ProvisioningService
    var boxProvisioningObserver: NSObjectProtocol!
    var itemProvisioningObserver: NSObjectProtocol!
    
    public var consumer: ConsumesBoxAndItem?
    
    public init(provisioningService: ProvisioningService) {
        self.provisioningService = provisioningService
        self.subscribe()
    }
    
    func subscribe() {
        let mainQueue = NSOperationQueue.mainQueue()
        let publisher = DomainEventPublisher.defaultCenter()
        
        self.boxProvisioningObserver = publisher.addObserverForName(kBoxProvisioned, object: nil, queue: mainQueue) {
            [unowned self] (notification: NSNotification!) in
            
            if notification.userInfo == nil {
                return
            }
            
            let boxId = self.boxId(notification.userInfo!)
            self.didAddBox(boxId)
        }

        self.itemProvisioningObserver = publisher.addObserverForName(kBoxItemProvisioned, object: nil, queue: mainQueue) {
            [unowned self] (notification: NSNotification!) in
            
            if notification.userInfo == nil {
                return
            }
            
            let itemId = self.itemId(notification.userInfo!)
            let boxId = self.boxId(notification.userInfo!)
            self.didAddItem(itemId, inBox: boxId)
        }
    }
    
    func boxId(userInfo: [NSObject : AnyObject]) -> BoxId {
        let boxInfo = userInfo["boxId"] as NSNumber
        return BoxId(boxInfo.longLongValue)
    }
    
    func itemId(userInfo: [NSObject : AnyObject]) -> ItemId {
        let itemInfo = userInfo["itemId"] as NSNumber
        return ItemId(itemInfo.longLongValue)
    }
    
    func didAddBox(boxId: BoxId) {
        if consumer == nil {
            return
        }
        
        let box = repository.box(boxId: boxId)
        let boxData = BoxData(boxId: boxId, title: box!.title, itemData: [])
        
        consumer!.consume(boxData)
    }
    
    func didAddItem(itemId: ItemId, inBox boxId: BoxId) {
        if consumer == nil {
            return
        }
    
        let box = repository.box(boxId: boxId)
        let item = box!.item(itemId: itemId)
        let itemData = ItemData(itemId: itemId, title: item!.title, boxId: boxId)
        
        consumer!.consume(itemData)
    }
    
    var repository: BoxRepository! {
        return ServiceLocator.boxRepository()
    }

    public func createBox() {
        provisioningService.provisionBox()
    }
    
    public func createItem(boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            provisioningService.provisionItem(inBox: box)
        }
    }
        
    public func changeBoxTitle(boxId: BoxId, title: String) {
        if let box = repository.box(boxId: boxId) {
            box.title = title
        }
    }
    
    public func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            // TODO add changeItemTitle()
            if let item = box.item(itemId: itemId) {
                item.title = title
            }
        }
    }
    
    public func removeBox(boxId: BoxId) {
        repository.removeBox(boxId: boxId)
    }
    
    public func removeItem(itemId: ItemId, fromBox boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            box.removeItem(itemId: itemId)
        }
    }
}

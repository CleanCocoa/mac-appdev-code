//
//  DisplayBoxesAndItems.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public protocol ConsumesBoxAndItem: class {
    func consume(boxData: BoxData)
    func consume(itemData: ItemData)
}

class DisplayBoxesAndItems {
    var boxProvisioningObserver: NSObjectProtocol!
    var itemProvisioningObserver: NSObjectProtocol!
    
    var consumer: ConsumesBoxAndItem?

    var publisher: NSNotificationCenter! {
        return DomainEventPublisher.defaultCenter()
    }
    
    init() {
        self.subscribe()
    }
    
    func subscribe() {
        let mainQueue = NSOperationQueue.mainQueue()
        
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
    
    deinit {
        unsubscribe()
    }
    
    func unsubscribe() {
        publisher.removeObserver(boxProvisioningObserver)
        publisher.removeObserver(itemProvisioningObserver)
    }
    
    
    //MARK: Domain Event Callbacks
    
    var repository: BoxRepository! {
        return ServiceLocator.boxRepository()
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
}
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

    var publisher: DomainEventPublisher! {
        return DomainEventPublisher.sharedInstance
    }
    
    init() {
        self.subscribe()
    }
    
    func subscribe() {
        let mainQueue = NSOperationQueue.mainQueue()
        
        self.boxProvisioningObserver = publisher.subscribe(BoxProvisionedEvent.self, queue: mainQueue) {
            [unowned self] (event: BoxProvisionedEvent!) in

            self.didAddBox(event.boxId, title: event.title)
        }
        
        self.itemProvisioningObserver = publisher.subscribe(BoxItemProvisionedEvent.self, queue: mainQueue) {
            [unowned self] (event: BoxItemProvisionedEvent!) in
            
            self.didAddItem(event.itemId, title: event.itemTitle, inBox: event.boxId)
        }
    }
    
    
    deinit {
        unsubscribe()
    }
    
    func unsubscribe() {
        publisher.unsubscribe(boxProvisioningObserver)
        publisher.unsubscribe(itemProvisioningObserver)
    }
    
    
    //MARK: Domain Event Callbacks
    
    var repository: BoxRepository! {
        return ServiceLocator.boxRepository()
    }
    
    func didAddBox(boxId: BoxId, title: String) {
        if consumer == nil {
            return
        }
        
        let boxData = BoxData(boxId: boxId, title: title, itemData: [])
        consumer!.consume(boxData)
    }
    
    func didAddItem(itemId: ItemId, title: String, inBox boxId: BoxId) {
        if consumer == nil {
            return
        }
        
        let itemData = ItemData(itemId: itemId, title: title, boxId: boxId)
        consumer!.consume(itemData)
    }
}
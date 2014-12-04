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
        
        boxProvisioningObserver = publisher.subscribe(BoxProvisionedEvent.self, queue: mainQueue) {
            [unowned self] (event: BoxProvisionedEvent!) in

            let boxData = BoxData(boxId: event.boxId, title: event.title)
            self.consumeBox(boxData)
        }
        
        itemProvisioningObserver = publisher.subscribe(BoxItemProvisionedEvent.self, queue: mainQueue) {
            [unowned self] (event: BoxItemProvisionedEvent!) in
            
            let itemData = ItemData(itemId: event.itemId, title: event.itemTitle, boxId: event.boxId)
            self.consumeItem(itemData)
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
    
    //TODO: rename "consume" to something better
    func consumeBox(boxData: BoxData) {
        if let consumer = self.consumer {
            consumer.consume(boxData)
        }
    }
    
    func consumeItem(itemData: ItemData) {
        if let consumer = self.consumer {
            consumer.consume(itemData)
        }
    }
}
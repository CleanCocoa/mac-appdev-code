//
//  HandleBoxAndItemModifications.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 25.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

class HandleBoxAndItemModifications: HandlesItemListEvents {
    let provisioningService: ProvisioningService
    
    // This could be injected since it's needed for ProvisioningService setup
    // anyway. Since the ServiceLocator is easily available in this layer, 
    // there's no benefit architecture-wise.
    var repository: BoxRepository! {
        return ServiceLocator.boxRepository()
    }
    
    init(provisioningService: ProvisioningService) {
        self.provisioningService = provisioningService
    }
    
    func createBox() {
        provisioningService.provisionBox()
    }
    
    func createItem(boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            provisioningService.provisionItem(inBox: box)
        }
    }
        
    func changeBoxTitle(boxId: BoxId, title: String) {
        if let box = repository.box(boxId: boxId) {
            box.title = title
        }
    }
    
    func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            // TODO add changeItemTitle()
            if let item = box.item(itemId: itemId) {
                item.title = title
            }
        }
    }
    
    func removeBox(boxId: BoxId) {
        repository.removeBox(boxId: boxId)
    }
    
    func removeItem(itemId: ItemId, fromBox boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
            box.removeItem(itemId: itemId)
        }
    }
}

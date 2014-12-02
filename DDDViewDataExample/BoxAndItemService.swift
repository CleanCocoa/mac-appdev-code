//
//  BoxAndItemService.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 25.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class BoxAndItemService: HandlesItemListEvents {
    public init() { }
    
    lazy var repository = ServiceLocator.boxRepository()

    public func provisionNewBoxId() -> BoxId {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, title: "New Box")
        
        repository.addBox(box)
        
        return boxId
    }
    
    public func provisionNewItemId(inBox boxId: BoxId) -> ItemId {
        let itemId = repository.nextItemId()
        
        if let box = repository.box(boxId: boxId) {
            let item = Item(itemId: itemId, title: "New Item")
            box.addItem(item)
        }
        
        return itemId //TODO: return NotFound ID
    }
    
    public func changeBoxTitle(boxId: BoxId, title: String) {
        if let box = repository.box(boxId: boxId) {
            box.title = title
        }
    }
    
    public func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
        if let box = repository.box(boxId: boxId) {
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

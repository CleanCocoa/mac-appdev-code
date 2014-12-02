//
//  BoxAndItemData.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 02/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public protocol HandlesItemListEvents: class {
    func provisionNewBoxId() -> BoxId
    func provisionNewItemId(inBox boxId: BoxId) -> ItemId
    
    func changeBoxTitle(boxId: BoxId, title: String)
    func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId)
    
    func removeBox(boxId: BoxId)
    func removeItem(itemId: ItemId, fromBox boxId: BoxId)
}

public struct BoxData {
    let boxId: BoxId
    let title: String
    let itemData: [ItemData]
    
    public init(boxId: BoxId, title: String, itemData: [ItemData]) {
        self.boxId = boxId
        self.title = title
        self.itemData = itemData
    }
}

public struct ItemData {
    let itemId: ItemId
    let title: String
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
}

//
//  ManageBoxesAndItems.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 28.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class ManageBoxesAndItems {
    lazy var boxAndItemService: BoxAndItemService! = {
        let provisioningService = ProvisioningService(repository: ServiceLocator.boxRepository())
        return BoxAndItemService(provisioningService: provisioningService)
    }()

    lazy var windowController: ItemManagementWindowController! = {
        let controller = ItemManagementWindowController()
        controller.loadWindow()
        controller.eventHandler = self.boxAndItemService
        self.boxAndItemService.consumer = controller.itemViewController
        return controller
    }()
    
    public init() { }
    
    public lazy var itemViewController: ItemViewController = {
        return self.windowController.itemViewController
    }()
    
    public func showBoxManagementWindow() {
        displayBoxes()
        showWindow()
    }
    
    func displayBoxes() {
        let repository = ServiceLocator.boxRepository()
        let allBoxes = repository.boxes()
        let allBoxData = boxData(allBoxes)
        
        windowController.displayBoxData(allBoxData)
    }
    
    func boxData(boxes: [Box]) -> [BoxData] {
        let allBoxData: [BoxData] = boxes.map() { (box: Box) -> BoxData in
            let allItemData: [ItemData] = self.itemData(box.items)
            
            return BoxData(boxId: box.boxId, title: box.title, itemData: allItemData)
        }
        
        return allBoxData
    }
    
    func itemData(items: [Item]) -> [ItemData] {
        return items.map() { (item: Item) -> ItemData in
            return ItemData(itemId: item.itemId, title: item.title)
        }
    }
    
    func showWindow() {
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
}

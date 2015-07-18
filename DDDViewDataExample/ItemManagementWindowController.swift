//
//  ItemManagementWindowController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public let kItemManagementWindowNibName: String = "ItemManagementWindowController"

public class ItemManagementWindowController: NSWindowController {
    
    public weak var eventHandler: HandlesItemListEvents? {
        get {
            return self.itemViewController.eventHandler
        }
        set {
            if let _ = self.window {
                // Ensure Nib is loaded
                self.itemViewController.eventHandler = newValue
            }
        }
    }
    
    @IBOutlet public var itemViewController: ItemViewController!
    
    /// Initialize using the default Nib
    public convenience init() {
        self.init(windowNibName: kItemManagementWindowNibName)
    }

    public override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    public func displayBoxData(boxData: [BoxData]) {
        itemViewController.displayBoxData(boxData)
    }
    
}

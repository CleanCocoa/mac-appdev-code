//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class ItemViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet public weak var itemsController: NSArrayController!
    
    public var tableView: NSTableView {
        return self.view as NSTableView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
}

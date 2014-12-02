//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

@objc(TreeNode)
public protocol TreeNode {
    var title: String { get set }
    var count: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    weak var eventHandler: HandlesItemListChanges? { get }
}

@objc(HandlesItemListChanges)
public protocol HandlesItemListChanges: class {
    func treeNodeDidChange(treeNode: TreeNode, title: String)
}

public class BoxNode: NSObject, TreeNode {
    public dynamic var title: String = "New Box" {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf: Bool = false
    public let boxId: BoxId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(boxData: BoxData) {
        self.boxId = boxData.boxId
        self.title = boxData.title
        super.init()
    }
}

public class ItemNode: NSObject, TreeNode {
    public dynamic var title: String = "New Item" {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf = true
    public let itemId: ItemId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(itemData: ItemData) {
        self.itemId = itemData.itemId
        self.title = itemData.title
    }
    
    public func parentBoxNode(inArray nodes: [BoxNode]) -> BoxNode? {
        for boxNode in nodes {
            if contains(boxNode.children as [ItemNode], self) {
                return boxNode
            }
        }
        
        return nil
    }
}


public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

public class ItemViewController: NSViewController, NSOutlineViewDelegate, HandlesItemListChanges {

    public weak var eventHandler: HandlesItemListEvents!
    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addBoxButton: NSButton!
    @IBOutlet public weak var addItemButton: NSButton!
    
    public var outlineView: NSOutlineView {
        return self.view as NSOutlineView
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
    
    func nodeCount() -> Int {
        return itemsController.arrangedObjects.childNodes!!.count
    }
    
    func hasSelection() -> Bool {
        return itemsController.selectedObjects.count > 0
    }
    
    
    //MARK: Populate View
    
    public func displayBoxData(boxData: [BoxData]) {
        removeExistingNodes()
        for data in boxData {
            itemsController.addObject(boxNode(data))
        }
    }

    func removeExistingNodes() {
        itemsController.content = NSMutableArray()
    }
    
    func boxNode(boxData: BoxData) -> BoxNode {
        let boxNode = BoxNode(boxData: boxData)
        boxNode.eventHandler = self
        boxNode.children = itemNodes(boxData.itemData)
        
        return boxNode
    }
    
    func itemNodes(allItemData: [ItemData]) -> [ItemNode] {
        var result: [ItemNode] = allItemData.map() { (itemData: ItemData) -> ItemNode in
            self.itemNode(itemData)
        }
        return result
    }
    
    func itemNode(itemData: ItemData) -> ItemNode {
        let itemNode = ItemNode(itemData: itemData)
        itemNode.eventHandler = self
        
        return itemNode
    }

    
    //MARK: Add Boxes
    
    @IBAction public func addBox(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            let boxNode = self.boxNode()
            let indexPath = NSIndexPath(index: nodeCount())
            itemsController.insertObject(boxNode, atArrangedObjectIndexPath: indexPath)
            orderTree()
        }
    }
    
    func boxNode() -> BoxNode {
        let boxId = eventHandler.provisionNewBoxId()
        let boxNode = BoxNode(boxId: boxId)
        boxNode.eventHandler = self
        
        return boxNode
    }
    
    func orderTree() {
        itemsController.rearrangeObjects()
    }
    
    
    //MARK: Add Items
    
    @IBAction public func addItem(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            addItemNodeToSelectedBox()
            orderTree()
        }
    }
    
    func addItemNodeToSelectedBox() {
        if let selectionIndexPath = boxIndexPathInSelection() {
            appendItemNodeToBoxIndexPath(selectionIndexPath)
        }
    }
    
    /// The indexPath of the first node if it's a BoxNode.
    func boxIndexPathInSelection() -> NSIndexPath? {
        if (!hasSelection()) {
            return nil
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first! as NSTreeNode
        
        if (treeNodeRepresentsBoxNode(firstSelectedTreeNode)) {
            let parentNode = firstSelectedTreeNode.parentNode!
            return parentNode.indexPath
        }
        
        return firstSelectedTreeNode.indexPath
    }
    
    func treeNodeRepresentsBoxNode(treeNode: NSTreeNode) -> Bool {
        return treeNode.leaf
    }
    
    func appendItemNodeToBoxIndexPath(parentIndexPath: NSIndexPath) {
        let parentTreeNode = boxTreeNodeAtIndexPath(parentIndexPath)
        let itemIndexPath = indexPath(appendedToTreeNode: parentTreeNode)
        let item = itemNode(belowBoxTreeNode: parentTreeNode)
        
        itemsController.insertObject(item, atArrangedObjectIndexPath: itemIndexPath)
    }
    
    func indexPath(appendedToTreeNode treeNode: NSTreeNode) -> NSIndexPath {
        let parentIndexPath = treeNode.indexPath
        let childNodeCount = treeNode.childNodes!.count
        return parentIndexPath.indexPathByAddingIndex(childNodeCount)
    }
    
    func itemNode(belowBoxTreeNode boxTreeNode: NSTreeNode)-> ItemNode {
        let boxNode = boxTreeNode.representedObject as BoxNode
        let itemId = eventHandler.provisionNewItemId(inBox: boxNode.boxId)
        let itemNode = ItemNode(itemId: itemId)
        itemNode.eventHandler = self
        
        return itemNode
    }
    
    func boxTreeNodeAtIndexPath(indexPath: NSIndexPath) -> NSTreeNode {
        assert(indexPath.length == 1, "assumes index path of a box with 1 index only")
        
        let boxNodes: [AnyObject] = itemsController.arrangedObjects.childNodes!!
        let boxIndex = indexPath.indexAtPosition(0)
        let boxNode = boxNodes[boxIndex] as NSTreeNode
        
        return boxNode
    }
    
    
    //MARK: Change items
    
    public func treeNodeDidChange(treeNode: TreeNode, title: String) {
        if let boxNode = treeNode as? BoxNode {
            eventHandler.changeBoxTitle(boxNode.boxId, title: boxNode.title)
        } else if let itemNode = treeNode as? ItemNode {
            if let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                eventHandler.changeItemTitle(itemNode.itemId, title: itemNode.title, inBox: boxNode.boxId)
            }
        }
    }
    
    /// Returns all of `itemsController` root-level nodes' represented objects
    func boxNodes() -> [BoxNode] {
        let rootNodes = itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
        return rootNodes.map { (treeNode: NSTreeNode) -> BoxNode in
            return treeNode.representedObject as BoxNode
        }
    }
}

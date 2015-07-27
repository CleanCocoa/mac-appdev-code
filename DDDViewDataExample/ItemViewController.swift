import Cocoa

@objc(TreeNode)
public protocol TreeNode: class {
    var title: String { get set }
    var count: UInt { get }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    
    func resetTitleToDefaultTitle()
}

@objc(HandlesItemListChanges)
public protocol HandlesItemListChanges: class {
    func treeNodeDidChange(treeNode: TreeNode, title: String)
}

@objc(NonNilStringValueTransformer)
public class NonNilStringValueTransformer: NSValueTransformer {
    override public func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let value = value else {
            return ""
        }
        
        return value
    }
}

extension Box: TreeNode {
    
    public dynamic var count: UInt { return 0 }
    
    public dynamic var children: [TreeNode] {
        return self.managedItems.map { $0 as! TreeNode }
    }
    
    public dynamic var isLeaf: Bool { return false }
    
    public func resetTitleToDefaultTitle() {
        title = "Box"
    }
}

extension Item: TreeNode {
    
    public dynamic var count: UInt { return 0 }
    
    public dynamic var children: [TreeNode] { return [] }
    
    public dynamic var isLeaf: Bool { return true }
    
    public func resetTitleToDefaultTitle() {
        title = "Item"
    }
}

public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

public class ItemViewController: NSViewController, NSOutlineViewDelegate {

    public weak var eventHandler: HandlesItemListEvents!
    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addBoxButton: NSButton!
    @IBOutlet public weak var addItemButton: NSButton!
    @IBOutlet public weak var removeButton: NSButton!
    
    var managedObjectContext: NSManagedObjectContext {
        return ServiceLocator.sharedInstance.managedObjectContext!
    }
    
    var repo: BoxRepository {
        return ServiceLocator.boxRepository()
    }
    
    public var outlineView: NSOutlineView {
        return self.view as! NSOutlineView
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
    
    
    //MARK: Add Boxes
    
    @IBAction public func addBox(sender: AnyObject) {
        guard let eventHandler = self.eventHandler else {
            return
        }
        
        eventHandler.createBox()
    }
    
    // TODO call order tree somewhere?
    func orderTree() {
        itemsController.rearrangeObjects()
    }
    
    
    //MARK: Add Items
    
    @IBAction public func addItem(sender: AnyObject) {
        addItemNodeToSelectedBox()
    }
    
    func addItemNodeToSelectedBox() {
        guard let selectionIndexPath = boxIndexPathInSelection() else {
            return
        }
        
        appendItemNodeToBoxIndexPath(selectionIndexPath)
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
        guard let eventHandler = eventHandler else {
            return
        }
        
        let parentTreeNode = boxTreeNodeAtIndexPath(parentIndexPath)
        let boxNode = parentTreeNode.representedObject as! Box
        eventHandler.createItem(boxNode.boxId)
    }
    
    func boxTreeNodeAtIndexPath(indexPath: NSIndexPath) -> NSTreeNode {
        precondition(indexPath.length == 1, "assumes index path of a box with 1 index only")
        
        let boxNodes: [AnyObject] = itemsController.arrangedObjects.childNodes!!
        let boxIndex = indexPath.indexAtPosition(0)
        let boxNode = boxNodes[boxIndex] as! NSTreeNode
        
        return boxNode
    }
    
    
    //MARK: Remove items
    
    @IBAction public func removeSelectedObject(sender: AnyObject) {
        if (!hasSelection()) {
            return
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first! as NSTreeNode
        let indexPath = firstSelectedTreeNode.indexPath
        let treeNode: TreeNode = firstSelectedTreeNode.representedObject as! TreeNode

        if let boxNode = treeNode as? Box {
            eventHandler.removeBox(boxNode.boxId)
        } else if let itemNode = treeNode as? Item {
            
            eventHandler.removeItem(itemNode.itemId, fromBox: itemNode.box.boxId)
        }
        
        itemsController.removeObjectAtArrangedObjectIndexPath(indexPath)
    }
}

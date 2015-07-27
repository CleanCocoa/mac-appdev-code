import Cocoa

@objc(TreeNode)
public protocol TreeNode: class {
    var title: String { get set }
    var count: UInt { get }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    
    func resetTitleToDefaultTitle()
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

    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addBoxButton: NSButton!
    @IBOutlet public weak var addItemButton: NSButton!
    @IBOutlet public weak var removeButton: NSButton!
    
    var managedObjectContext: NSManagedObjectContext {
        return ServiceLocator.sharedInstance.managedObjectContext!
    }
        
    public var outlineView: NSOutlineView {
        return self.view as! NSOutlineView
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
    
    func hasSelection() -> Bool {
        return itemsController.selectedObjects.count > 0
    }
    
    
    //MARK: Add Boxes and Items
    
    var repository: BoxRepository!
    
    @IBAction public func addBox(sender: AnyObject) {
        guard hasValue(repository) else {
            return
        }
        
        let boxId = repository.nextId()
        repository.addBoxWithId(boxId, title: "NEW BOX!!")
        
        refreshTree()
    }
    
    @IBAction public func addItem(sender: AnyObject) {
        guard hasValue(repository) else {
            return
        }
        
        guard hasSelection() else {
            return
        }
        
        addItemToSelectedBox()
        
        refreshTree()
    }
    
    func addItemToSelectedBox() {
        let selectedNode = itemsController.selectedNodes.first!
        let itemId = repository.nextItemId()
        
        if let box = selectedNode.representedObject as? Box {
            box.addItemWithId(itemId, title: "NEW ITEM!!")
        } else if let item = selectedNode.representedObject as? Item {
            item.box.addItemWithId(itemId, title: "NEW sibling ITEM!!")
        }
    }
    
    func refreshTree() {
        itemsController.rearrangeObjects()
    }
    
    //MARK: Remove items
    
    @IBAction public func removeSelectedObject(sender: AnyObject) {
        guard hasSelection() else {
            return
        }

        let selectedNode = itemsController.selectedNodes.first!
        
        if let box = selectedNode.representedObject as? Box {
            repository.removeBox(boxId: box.boxId)
        } else if let item = selectedNode.representedObject as? Item {
            let itemId = item.itemId
            let box = item.box
            box.removeItem(itemId: itemId)
        }
        
        refreshTree()
    }
}

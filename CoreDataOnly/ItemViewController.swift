import Cocoa

@objc(TreeNode)
public protocol TreeNode: class {
    var title: String { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
}

@objc(NonNilStringValueTransformer)
open class NonNilStringValueTransformer: ValueTransformer {
    override open func transformedValue(_ value: Any?) -> Any? {
        guard let value = value else {
            return ""
        }
        
        return value
    }
}

extension Box: TreeNode {
    
    public dynamic var children: [TreeNode] {
        return self.managedItems.map { $0 as! TreeNode }
    }
    
    public dynamic var isLeaf: Bool { return false }
}

extension Item: TreeNode {
    
    public dynamic var children: [TreeNode] { return [] }
    
    public dynamic var isLeaf: Bool { return true }
}

public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

open class ItemViewController: NSViewController, NSOutlineViewDelegate {

    @IBOutlet open weak var itemsController: NSTreeController!
    @IBOutlet open weak var addBoxButton: NSButton!
    @IBOutlet open weak var addItemButton: NSButton!
    @IBOutlet open weak var removeButton: NSButton!
    
    var managedObjectContext: NSManagedObjectContext {
        return ServiceLocator.sharedInstance.managedObjectContext!
    }
        
    open var outlineView: NSOutlineView {
        return self.view as! NSOutlineView
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        return [sortByTitle]
    }
    
    func hasSelection() -> Bool {
        return itemsController.selectedObjects.count > 0
    }
    
    
    //MARK: Add Boxes and Items
    
    var repository: BoxRepository!
    
    @IBAction open func addBox(_ sender: AnyObject) {
        guard hasValue(repository) else {
            return
        }
        
        let boxId = repository.nextId()
        repository.addBoxWithId(boxId, title: "NEW BOX!!")
        
        refreshTree()
    }
    
    @IBAction open func addItem(_ sender: AnyObject) {
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
    
    @IBAction open func removeSelectedObject(_ sender: AnyObject) {
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

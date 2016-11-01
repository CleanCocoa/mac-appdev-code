import Foundation
import CoreData

private var boxContext = 0

@objc(ManagedBox)
open class ManagedBox: NSManagedObject, ManagedEntity {

    @NSManaged open var creationDate: Date
    @NSManaged open var modificationDate: Date
    @NSManaged open var title: String
    @NSManaged open var uniqueId: NSNumber
    @NSManaged open var items: NSSet
    
    open static var entityName: String {
        return "ManagedBox"
    }
        
    open static func insertManagedBox(_ boxId: BoxId, title: String, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let managedBox: ManagedBox = self.create(into: managedObjectContext)
        
        managedBox.uniqueId = uniqueIdFromBoxId(boxId)
        managedBox.title = title
    }
    
    static func uniqueIdFromBoxId(_ boxId: BoxId) -> NSNumber {
        return NSNumber(value: boxId.identifier)
    }
    
    open func boxId() -> BoxId {
        return BoxId(uniqueId.int64Value)
    }
    
    
    //MARK: -
    //MARK: Box Management
    
    fileprivate var _box: Box?
    open lazy var box: Box = {
        let box = self.createBox()
        self.observe(box)
        self._box = box
        return box
    }()
    
    func createBox() -> Box {
        let box = Box(boxId: self.boxId(), title: self.title)
        box.items = self.associatedItems()
        
        return box
    }
    
    func associatedItems() -> [Item] {
        let managedItems = self.items.allObjects as! [ManagedItem]
        return managedItems.map() { (item: ManagedItem) -> Item in
            return item.item
        }
    }
    
    func observe(_ box: Box) {
        box.addObserver(self, forKeyPath: "title", options: .new, context: &boxContext)
        box.addObserver(self, forKeyPath: "items", options: .new, context: &boxContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &boxContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change?[.newKey] as! String
        } else if keyPath == "items" {
            let items = change?[.newKey] as! [Item]
            mergeItems(items)
        }
    }
    
    func mergeItems(_ items: [Item]) {
        let existingItems = self.mutableSetValue(forKey: "items")
        removeMissing(items: items, from: existingItems)
        addNewItems(of: items, to: existingItems)
    }

    fileprivate func removeMissing(items: [Item], from existingItems: NSMutableSet) {
        for item in existingItems {
            guard let managedItem: ManagedItem = item as? ManagedItem
                else { continue }
            
            if !items.contains(managedItem.item) {
                existingItems.remove(item)
            }
        }
    }

    fileprivate func addNewItems(of items: [Item], to existingItems: NSMutableSet) {

        for item in items {
            let itemIsInExistingItems = existingItems.contains {
                let managedItem = $0 as! ManagedItem
                return managedItem.item == item
            }

            if !itemIsInExistingItems {
                ManagedItem.insertManagedItem(item, managedBox: self, inManagedObjectContext: managedObjectContext!)
            }
        }
    }

    // MARK: Destructor
    
    deinit {
        if let box = _box {
            unobserve(box)
        }
    }

    fileprivate func unobserve(_ box: Box) {
        box.removeObserver(self, forKeyPath: "title")
        box.removeObserver(self, forKeyPath: "items")
    }
}

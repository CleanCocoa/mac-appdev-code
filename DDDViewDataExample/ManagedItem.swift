import Foundation
import CoreData

private var itemContext = 0

@objc(ManagedItem)
open class ManagedItem: NSManagedObject, ManagedEntity {
    
    @NSManaged open var uniqueId: NSNumber
    @NSManaged open var title: String
    @NSManaged open var creationDate: Date
    @NSManaged open var modificationDate: Date
    @NSManaged open var box: ManagedBox

    open class func entityName() -> String {
        return "ManagedItem"
    }
    
    open class func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }
    
    open class func insertManagedItem(_ item: Item, managedBox: ManagedBox, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let theItem: AnyObject = NSEntityDescription.insertNewObject(forEntityName: entityName(), into: managedObjectContext)
        let managedItem: ManagedItem = theItem as! ManagedItem
        
        managedItem.item = item
        managedItem.box = managedBox
    }
    
    class func uniqueIdFromItemId(_ itemId: ItemId) -> NSNumber {
        return NSNumber(value: itemId.identifier as Int64)
    }
    
    open func itemId() -> ItemId {
        return ItemId(self.uniqueId.int64Value)
    }
    
    //MARK: -
    //MARK: Item Management
    
    fileprivate var _item: Item?
    open var item: Item {
        get {
            if let item = _item {
                return item
            }
            
            let item = Item(itemId: self.itemId(), title: self.title)
            // TODO add back-reference to box
            observe(item)
            
            
            _item = item
            
            return item
        }
        set {
            precondition(!hasValue(_item), "can be set only before lazy initialization of item")
            
            let item = newValue
            adapt(item)
            observe(item)
            
            _item = item
        }
    }
    
    func observe(_ item: Item) {
        item.addObserver(self, forKeyPath: "title", options: .new, context: &itemContext)
    }
    
    func adapt(_ item: Item) {
        uniqueId = ManagedItem.uniqueIdFromItemId(item.itemId)
        title = item.title
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context != &itemContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change?[NSKeyValueChangeKey.newKey] as! String
        }
    }
    
    deinit {
        if let item = _item {
            item.removeObserver(self, forKeyPath: "title")
        }
    }
    
}

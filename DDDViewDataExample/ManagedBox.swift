import Foundation
import CoreData

private var boxContext = 0

@objc(ManagedBox)
public class ManagedBox: NSManagedObject, ManagedEntity {

    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var title: String
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var items: NSSet
    
    public class func entityName() -> String {
        return "ManagedBox"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedBox(boxId: BoxId, title: String, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        
        let box: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext)
        let managedBox: ManagedBox = box as! ManagedBox
        
        managedBox.uniqueId = uniqueIdFromBoxId(boxId)
        managedBox.title = title
    }
    
    class func uniqueIdFromBoxId(boxId: BoxId) -> NSNumber {
        return NSNumber(longLong: boxId.identifier)
    }
    
    public func boxId() -> BoxId {
        return BoxId(uniqueId.longLongValue)
    }
    
    
    //MARK: -
    //MARK: Box Management
    
    private var _box: Box?
    public lazy var box: Box = {
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
    
    func observe(box: Box) {
        box.addObserver(self, forKeyPath: "title", options: .New, context: &boxContext)
        box.addObserver(self, forKeyPath: "items", options: .New, context: &boxContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context != &boxContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            self.title = change?[NSKeyValueChangeNewKey] as! String
        } else if keyPath == "items" {
            let items = change?[NSKeyValueChangeNewKey] as! [Item]
            mergeItems(items)
        }
    }
    
    func mergeItems(items: [Item]) {
        let existingItems = self.mutableSetValueForKey("items")
        removeMissingItems(items, from: existingItems)
        addNewItems(items, to: existingItems)
    }
    
    func removeMissingItems(items: [Item], from existingItems: NSMutableSet) {
        for item in existingItems {
            if let managedItem: ManagedItem = item as? ManagedItem {
                if !items.contains(managedItem.item) {
                    existingItems.removeObject(item)
                }
            }
        }
    }
    
    func addNewItems(items: [Item], to existingItems: NSMutableSet) {
        for item in items {
            let itemIsInExistingItems = existingItems.contains({ (existingItem: AnyObject) -> Bool in
                let managedItem = existingItem as! ManagedItem
                return managedItem.item == item
            })
            
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

    func unobserve(box: Box) {
        box.removeObserver(self, forKeyPath: "title")
        box.removeObserver(self, forKeyPath: "items")
    }
}

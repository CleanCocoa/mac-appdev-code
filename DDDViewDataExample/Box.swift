import Cocoa

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBox(_ box: Box)
    func removeBox(boxId: BoxId)
    func boxes() -> [Box]
    func box(boxId: BoxId) -> Box?
    func count() -> Int
}

open class Box: NSObject {
    open let boxId: BoxId
    open dynamic var title: String
    dynamic var items: [Item] = []
    
    public init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    open func addItem(_ item: Item) {
        precondition(!hasValue(item.box), "item should not have a parent box already")
        
        items.append(item)
    }
    
    open func item(itemId: ItemId) -> Item? {
        guard let index = indexOfItem(itemId: itemId) else {
            return nil
        }
        
        return items[index]
    }
    
    open func removeItem(itemId: ItemId) {
        guard let index = indexOfItem(itemId: itemId) else {
            return
        }
        
        items.remove(at: index)
    }
    
    func indexOfItem(itemId: ItemId) -> Int? {
        for (index, item) in items.enumerated() {
            if item.itemId == itemId {
                return index
            }
        }
        
        return nil
    }
}

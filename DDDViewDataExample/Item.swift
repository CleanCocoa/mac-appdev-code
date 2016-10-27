import Cocoa

public protocol ItemRepository {
    func nextId() -> ItemId
    func addItem(_ item: Item)
    func items() -> Array<Item>
    func count() -> UInt
}

open class Item: NSObject {
    open let itemId: ItemId
    open dynamic var title: String
    open var box: Box?
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Item else {
            return false
        }
        
        return other.itemId == self.itemId
    }
    
    open override var hashValue: Int {
        return 173 &+ self.itemId.hashValue
    }
}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.itemId == rhs.itemId
}

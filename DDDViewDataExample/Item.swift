import Cocoa

public protocol ItemRepository {
    func nextId() -> ItemId
    func addItem(item: Item)
    func items() -> Array<Item>
    func count() -> UInt
}

public class Item: NSObject {
    public let itemId: ItemId
    public dynamic var title: String
    public var box: Box?
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Item {
            return other.itemId == self.itemId
        }
        
        return false
    }
    
    public override var hashValue: Int {
        return 173 &+ self.itemId.hashValue
    }
}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.itemId == rhs.itemId
}

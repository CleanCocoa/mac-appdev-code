import Cocoa

public struct BoxId: Equatable, CustomDebugStringConvertible, Identifiable {
    public var identifier: IntegerId { return _identifier }
    private var _identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        _identifier = identifier
    }
    
    init(_ identifierNumber: NSNumber) {
        _identifier = identifierNumber.longLongValue
    }
    
    public var debugDescription: String {
        return "BoxId: \(identifier)"
    }
}

public func ==(lhs: BoxId, rhs: BoxId) -> Bool {
    return lhs.identifier == rhs.identifier
}

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBox(box: Box)
    func removeBox(boxId boxId: BoxId)
    func boxes() -> [Box]
    func box(boxId boxId: BoxId) -> Box?
    func count() -> Int
}


public class Box: NSObject {
    public let boxId: BoxId
    public dynamic var title: String
    dynamic var items: [Item] = []
    
    public init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    public func addItem(item: Item) {
        precondition(!hasValue(item.box), "item should not have a parent box already")
        
        items.append(item)
    }
    
    public func item(itemId itemId: ItemId) -> Item? {
        guard let index = indexOfItem(itemId: itemId) else {
            return nil
        }
        
        return items[index]
    }
    
    public func removeItem(itemId itemId: ItemId) {
        guard let index = indexOfItem(itemId: itemId) else {
            return
        }
        
        items.removeAtIndex(index)
    }
    
    func indexOfItem(itemId itemId: ItemId) -> Int? {
        for (index, item) in items.enumerate() {
            if item.itemId == itemId {
                return index
            }
        }
        
        return nil
    }
}

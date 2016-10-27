import Foundation

public struct ItemId: Identifiable {
    
    public let identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        self.identifier = identifier
    }

    init(fromNumber number: NSNumber) {
        self.identifier = number.int64Value
    }
}

extension ItemId: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "ItemId: \(identifier)"
    }
}

extension ItemId: Hashable {

    public var hashValue: Int {
        return self.identifier.hashValue
    }
}

extension ItemId: Equatable {  }

public func ==(lhs: ItemId, rhs: ItemId) -> Bool {
    
    return lhs.identifier == rhs.identifier
}

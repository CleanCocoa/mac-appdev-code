import Foundation

public struct BoxId: Identifiable {
    
    public let identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        self.identifier = identifier
    }

    init(fromNumber number: NSNumber) {
        self.identifier = number.int64Value
    }
}

extension BoxId: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "BoxId: \(identifier)"
    }
}

extension BoxId: Equatable {  }

public func ==(lhs: BoxId, rhs: BoxId) -> Bool {
    return lhs.identifier == rhs.identifier
}

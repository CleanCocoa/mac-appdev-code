import Foundation

public typealias IntegerId = Int64

public protocol Identifiable {
    var identifier: IntegerId { get }
    init(_ identifier: IntegerId)
}

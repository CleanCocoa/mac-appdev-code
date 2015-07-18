import Foundation

// TODO put this typealias into a helper file
public typealias IntegerId = Int64

public protocol Identifiable {
    var identifier: IntegerId { get }
    init(_ identifier: IntegerId)
}
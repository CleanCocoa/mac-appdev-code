import Foundation

// <http://owensd.io/2015/05/12/optionals-if-let.html>
func hasValue<T>(_ value: T?) -> Bool {
    switch value {
    case .some(_): return true
    case .none: return false
    }
}

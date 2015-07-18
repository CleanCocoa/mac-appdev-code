import Foundation

// <http://owensd.io/2015/05/12/optionals-if-let.html>
func hasValue<T>(value: T?) -> Bool {
    switch value {
    case .Some(_): return true
    case .None: return false
    }
}

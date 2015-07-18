import Cocoa
import XCTest

extension XCTestCase {
    func hasBinding(object: NSObject, binding:String, to boundObject: NSObject, throughKeyPath keyPath:String, transformingWith transformerName: String) -> Bool {
        
        if !hasBinding(object, binding: binding, to: boundObject, throughKeyPath: keyPath) {
            return false
        }
        
        if let info = object.infoForBinding(binding), options = info[NSOptionsKey] as? [String: AnyObject], boundTransformerName = options["NSValueTransformerName"] as? String {
            
            return boundTransformerName == transformerName
        }
        
        return false
    }
    
    func hasBinding(object: NSObject, binding:String, to boundObject: NSObject, throughKeyPath keyPath:String) -> Bool {
        if let info = object.infoForBinding(binding) {
            return (info[NSObservedObjectKey] as! NSObject == boundObject) && (info[NSObservedKeyPathKey] as! String == keyPath)
        }
        
        return false
    }
}

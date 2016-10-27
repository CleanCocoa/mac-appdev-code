import Cocoa

open class ServiceLocator {
    
    open static var sharedInstance: ServiceLocator {
        struct Static {
            static let instance: ServiceLocator = ServiceLocator()
        }
        return Static.instance
    }
    
    open static func resetSharedInstance() {
        sharedInstance.reset()
    }
    
    func reset() {
        managedObjectContext = nil
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    open func setManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) {
        precondition(!hasValue(self.managedObjectContext), "managedObjectContext can be set up only once")
        self.managedObjectContext = managedObjectContext
    }
    
    //MARK: Repository Access
    
    open static func boxRepository() -> BoxRepository {
        return sharedInstance.boxRepository()
    }
    
    open func boxRepository() -> BoxRepository {
        precondition(hasValue(managedObjectContext), "managedObjectContext must be set up")
        return CoreDataBoxRepository(managedObjectContext: managedObjectContext!)
    }
}

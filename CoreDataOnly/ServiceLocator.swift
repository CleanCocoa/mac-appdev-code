import Cocoa

open class ServiceLocator {

    open static let sharedInstance = ServiceLocator()

    open static func resetSharedInstance() {
        sharedInstance.reset()
    }

    fileprivate func reset() {
        managedObjectContext = nil
    }

    public fileprivate(set) var managedObjectContext: NSManagedObjectContext?

    public func setManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) {
        precondition(!hasValue(self.managedObjectContext), "managedObjectContext can be set up only once")
        self.managedObjectContext = managedObjectContext
    }

    //MARK: Repository Access

    public static func boxRepository() -> BoxRepository {
        return sharedInstance.boxRepository()
    }

    open func boxRepository() -> BoxRepository {
        guard let managedObjectContext = self.managedObjectContext
            else { preconditionFailure("managedObjectContext must be set up") }

        return CoreDataBoxRepository(managedObjectContext: managedObjectContext)
    }
}

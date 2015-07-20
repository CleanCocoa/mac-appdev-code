import CoreData

@objc(ManagedEntity)
protocol ManagedEntity: class {
    static func entityName() -> String
    static func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}
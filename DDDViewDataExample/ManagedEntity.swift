import CoreData

@objc(ManagedEntity)
protocol ManagedEntity: class {
    static func entityName() -> String
    static func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}

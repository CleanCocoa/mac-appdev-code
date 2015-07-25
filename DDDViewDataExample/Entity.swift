import CoreData

@objc(Entity)
protocol Entity: class {
    static func entityName() -> String
    static func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}
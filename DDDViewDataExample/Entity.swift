import CoreData

@objc(Entity)
protocol Entity: class {
    static var entityName: String { get }
    static func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}
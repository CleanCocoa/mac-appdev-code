import CoreData

protocol ManagedEntity: class {
    static var entityName: String { get }
    static func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}

extension ManagedEntity {

    static func entityDescriptionInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {

        return NSEntityDescription.entity(
            forEntityName: self.entityName,
            in: managedObjectContext)
    }

    static func create(into managedObjectContext: NSManagedObjectContext) -> Self {

        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: managedObjectContext) as! Self
    }
}

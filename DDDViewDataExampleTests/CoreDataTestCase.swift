import Cocoa
import XCTest
import CoreData

import DDDViewDataExample

class CoreDataTestCase: XCTestCase {
    /// Managed Object Model file name
    var modelName: String?
    
    /// Transiert temporary ManagedObjectContext
    internal lazy var context: NSManagedObjectContext = {
        guard let modelName = self.modelName else {
            preconditionFailure("modelName required. Call setUp() first")
        }
        
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        let bundle = NSBundle.mainBundle();
        
        guard let modelURL = bundle.URLForResource(modelName, withExtension: "momd") else {
            fatalError("model not loaded")
        }
        
        let model = NSManagedObjectModel(contentsOfURL: modelURL)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        let store: NSPersistentStore
        
        do {
            store = try coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch {
            fatalError("store not created")
        }
        
        context.persistentStoreCoordinator = coordinator
        
        return context
    }()
    
    override func setUp() {
        let modelName:String = kDefaultModelName
        self.setUpWithModelName(modelName)
    }
    
    func setUpWithModelName(modelName: String) {
        super.setUp()
        self.modelName = modelName
    }
}

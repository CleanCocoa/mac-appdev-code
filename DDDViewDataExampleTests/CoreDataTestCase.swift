import Cocoa
import XCTest
import CoreData

@testable import DDDViewDataExample

class CoreDataTestCase: XCTestCase {
    /// Managed Object Model file name
    var modelName: String?
    
    /// Transiert temporary ManagedObjectContext
    internal lazy var context: NSManagedObjectContext = {
        guard let modelName = self.modelName else {
            preconditionFailure("modelName required. Call setUp() first")
        }
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let bundle = Bundle.main
        
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("model not loaded")
        }
        
        let model = NSManagedObjectModel(contentsOf: modelURL)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        let store: NSPersistentStore
        
        do {
            store = try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
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
    
    func setUpWithModelName(_ modelName: String) {
        super.setUp()
        self.modelName = modelName
    }
}

import Cocoa

let kErrorDomain = "DDDViewDataExampleErrorDomain"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    lazy var persistentStack: PersistentStack = {
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("ItemModel.sqlite")
        let modelURL = Bundle.main.url(forResource: kDefaultModelName, withExtension: "momd")
        
        let persistentStack = PersistentStack(storeURL: storeURL, modelURL: modelURL!)
        
        self.notificationCenter.addObserver(persistentStack, selector: #selector(PersistentStack.objectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: persistentStack.managedObjectContext)
        
        return persistentStack
    }()

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "de.christiantietze.DDDViewDataExample" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1] as URL
        let directory = appSupportURL.appendingPathComponent("de.christiantietze.DDDViewDataExample")
        
        self.guardApplicationDocumentsDirectory(directory)
        
        return directory
    }()
    
    fileprivate func guardApplicationDocumentsDirectory(_ directory: URL) {
        
        do {
            if try !directoryExists(directory) {
                try createDirectory(directory)
            }
        } catch let error as NSError {
            NSApplication.shared().presentError(error)
            abort()
        }
    }
    
    fileprivate func directoryExists(_ directory: URL) throws -> Bool {
        
        let propertiesOpt: [AnyHashable: Any]
        
        do {
            propertiesOpt = try (directory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
        } catch let error as NSError {
            
            if error.code == NSFileReadNoSuchFileError {
                return false
            }
            
            throw error
        }
        
        if let isDirectory = propertiesOpt[URLResourceKey.isDirectoryKey] as? Bool,
            isDirectory == false {
            
            var userInfo = [AnyHashable: Any]()
            userInfo[NSLocalizedDescriptionKey] = "Failed to initialize the persistent stack"
            userInfo[NSLocalizedFailureReasonErrorKey] = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
            
            throw NSError(domain: kErrorDomain, code: 1, userInfo: userInfo)
        }
        
        return true
    }
    
    fileprivate func createDirectory(_ directory: URL) throws {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
        } catch let fileError as NSError {
            
            var userInfo = [AnyHashable: Any]()
            userInfo[NSLocalizedDescriptionKey] = "Failed to create the application documents directory"
            userInfo[NSLocalizedFailureReasonErrorKey] = "Creation of \(directory.path) failed."
            userInfo[NSUnderlyingErrorKey] = fileError
            
            throw NSError(domain: kErrorDomain, code: 1, userInfo: userInfo)
        }
    }
    
    //MARK: -
    //MARK: NSAppDelegate callbacks
    
    lazy var manageBoxesAndItems: ManageBoxesAndItems! = ManageBoxesAndItems()
    var readErrorCallback: NSObjectProtocol?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        subscribeToCoreDataReadErrors()
        
        ServiceLocator.sharedInstance.managedObjectContext = persistentStack.managedObjectContext
        manageBoxesAndItems.showBoxManagementWindow()
    }
    
    func subscribeToCoreDataReadErrors() {
        readErrorCallback = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: kCoreDataReadErrorNotificationName), object: nil, queue: OperationQueue.main) { notification in
            
            let question = NSLocalizedString("Could not read data. Report and Quit?", comment: "Read error quit question message")
            let info = NSLocalizedString("The application cannot read data and thus better not continues to operate. Changes will be saved if possible.", comment: "Read error quit question info")
            let quitButton = NSLocalizedString("Report and Quit", comment: "Report and Quit button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                //TODO: Add error reporting here
                return NSApplication.shared().terminate(self)
            }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        return persistentStack.saveToTerminate(sender)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if readErrorCallback != nil {
            notificationCenter.removeObserver(readErrorCallback!)
        }
        
        notificationCenter.removeObserver(persistentStack, name: NSNotification.Name.NSManagedObjectContextWillSave, object: persistentStack.managedObjectContext)
    }
    
    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return persistentStack.undoManager()
    }
}


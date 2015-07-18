import Cocoa

let kErrorDomain = "DDDViewDataExampleErrorDomain"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    lazy var persistentStack: PersistentStack = {
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ItemModel.sqlite");
        let modelURL = NSBundle.mainBundle().URLForResource(kDefaultModelName, withExtension: "momd")
        
        let persistentStack = PersistentStack(storeURL: storeURL, modelURL: modelURL!)
        
        self.notificationCenter.addObserver(persistentStack, selector: "objectContextWillSave", name: NSManagedObjectContextWillSaveNotification, object: persistentStack.managedObjectContext)
        
        return persistentStack
    }()

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "de.christiantietze.DDDViewDataExample" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        let directory = appSupportURL.URLByAppendingPathComponent("de.christiantietze.DDDViewDataExample")
        
        self.guardApplicationDocumentsDirectory(directory)
        
        return directory
    }()
    
    private func guardApplicationDocumentsDirectory(directory: NSURL) {
        
        do {
            if try !directoryExists(directory) {
                try createDirectory(directory)
            }
        } catch let error as NSError {
            NSApplication.sharedApplication().presentError(error)
            abort()
        }
        
    }
    
    private func directoryExists(directory: NSURL) throws -> Bool {
        
        let propertiesOpt: [NSObject: AnyObject]
        
        do {
            propertiesOpt = try directory.resourceValuesForKeys([NSURLIsDirectoryKey])
        } catch let error as NSError {
            
            if error.code == NSFileReadNoSuchFileError {
                return false
            }
            
            throw error
        }
        
        if let isDirectory = propertiesOpt[NSURLIsDirectoryKey]?.boolValue where isDirectory == false {
            
            var userInfo = [NSObject : AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = "Failed to initialize the persistent stack"
            userInfo[NSLocalizedFailureReasonErrorKey] = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
            
            throw NSError(domain: kErrorDomain, code: 1, userInfo: userInfo)
        }
        
        return true
    }
    
    private func createDirectory(directory: NSURL) throws {
        
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.createDirectoryAtPath(directory.path!, withIntermediateDirectories: true, attributes: nil)
        } catch let fileError as NSError {
            
            var userInfo = [NSObject : AnyObject]()
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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        subscribeToCoreDataReadErrors()
        
        ServiceLocator.sharedInstance.managedObjectContext = persistentStack.managedObjectContext
        manageBoxesAndItems.showBoxManagementWindow()
    }
    
    func subscribeToCoreDataReadErrors() {
        readErrorCallback = notificationCenter.addObserverForName(kCoreDataReadErrorNotificationName, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            
            let question = NSLocalizedString("Could not read data. Report and Quit?", comment: "Read error quit question message")
            let info = NSLocalizedString("The application cannot read data and thus better not continues to operate. Changes will be saved if possible.", comment: "Read error quit question info");
            let quitButton = NSLocalizedString("Report and Quit", comment: "Report and Quit button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                //TODO: Add error reporting here
                return NSApplication.sharedApplication().terminate(self)
            }
        }
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        return persistentStack.saveToTerminate(sender)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        if readErrorCallback != nil {
            notificationCenter.removeObserver(readErrorCallback!)
        }
        
        notificationCenter.removeObserver(persistentStack, name: NSManagedObjectContextWillSaveNotification, object: persistentStack.managedObjectContext)
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        return persistentStack.undoManager()
    }
}


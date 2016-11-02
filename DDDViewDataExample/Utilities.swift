import Foundation
import CoreData

func delay(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func dispatch_async_main(_ closure: @escaping () -> ()) {
    DispatchQueue.main.async(execute: closure)
}

func logDetailledErrors(_ error: Error) {
    let error = error as NSError
    if let detailedErrors: [NSError] = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
        for detailedError in detailedErrors {
            NSLog("  DetailedError: \(detailedError.userInfo)")
        }
    } else {
        NSLog("  \(error.userInfo)")
    }
}

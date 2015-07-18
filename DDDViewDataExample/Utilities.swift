import Foundation
import CoreData

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func dispatch_async_main(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func logDetailledErrors(error: NSError) {
    if let detailedErrors: [NSError] = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
        for detailedError in detailedErrors {
            NSLog("  DetailedError: \(detailedError.userInfo)")
        }
    } else {
        NSLog("  \(error.userInfo)")
    }
}

import Foundation
import CoreData

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + .milliseconds(Int(delay * 1000)),
        execute: closure)
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

func fatalMethodNotImplemented(_ function: String = #function) -> Never  {
    fatalError("Method \(function) not implemented")
}

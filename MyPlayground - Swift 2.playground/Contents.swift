
import Foundation
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

// Declare operations
let operation1 = CustomOperation1()
let operation2 = CustomOperation2()
let operation3 = CustomOperation1()

// Set operation3 to perform only after operation1 and operation1 have finished
operation3.addDependency(operation2)
operation3.addDependency(operation1)

// Launch operations
let queue = NSOperationQueue()
queue.addOperations([operation3, operation2, operation1], waitUntilFinished: false)

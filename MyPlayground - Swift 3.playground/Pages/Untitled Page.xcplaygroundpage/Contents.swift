
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// Declare operations
let operation1 = CustomOperation1()
let operation2 = CustomOperation2()
let operation3 = CustomOperation1()

// Set operation3 to perform only after operation1 and operation1 have finished
operation3.addDependency(operation2)
operation3.addDependency(operation1)

// Launch operations
let queue = OperationQueue()
queue.addOperations([operation2, operation3, operation1], waitUntilFinished: false)

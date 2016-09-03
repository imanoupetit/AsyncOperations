
import Foundation

open class CustomOperation1: AbstractOperation {
    
    override open func main() {
        if isCancelled {
            finish()
            return
        }
        
        // Perform some asynchronous operation
        let queue = DispatchQueue(label: "com.app.serialqueue1")
        let delay = DispatchTime.now() + .seconds(5)
        queue.asyncAfter(deadline: delay) {
            self.finish()
            print("\(self) finished")
        }
    }
    
}

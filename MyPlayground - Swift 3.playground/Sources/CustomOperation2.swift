
import Foundation

open class CustomOperation2: AbstractOperation {
    
    override open func main() {
        if isCancelled {
            finish()
            return
        }
        
        // Perform some asynchronous operation
        let queue = DispatchQueue(label: "com.app.serialqueue2")
        queue.async {
            self.finish()
            print("\(self) finished")
        }
    }
    
}

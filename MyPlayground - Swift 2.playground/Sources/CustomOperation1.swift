
import Foundation

public class CustomOperation1: AbstractOperation {
    
    override public func main() {
        if cancelled {
            finish()
            return
        }
        
        // Perform some asynchronous operation
        let queue = dispatch_queue_create("com.app.serial.queue", DISPATCH_QUEUE_SERIAL)
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(5) * Double(NSEC_PER_SEC)))
        dispatch_after(when, queue) {
            self.finish()
            print("\(self) finished")
        }
    }
    
}

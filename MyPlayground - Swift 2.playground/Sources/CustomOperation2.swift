
import Foundation

public class CustomOperation2: AbstractOperation {
    
    public override func main() {
        if cancelled {
            finish()
            return
        }
        
        // Perform some asynchronous operation
        let queue = dispatch_queue_create("com.app.serial.queue", DISPATCH_QUEUE_SERIAL)
        dispatch_sync(queue) {
            self.finish()
            print("\(self) finished")
        }
    }
    
}


import Foundation

/**
 NSOperation documentation:
 Operation objects are synchronous by default.
 At no time in your start method should you ever call super.
 When you add an operation to an operation queue, the queue ignores the value of the asynchronous property and always calls the start method from a separate thread.
 If you are creating a concurrent operation, you need to override the following methods and properties at a minimum:
    start, asynchronous, executing, finished.
 */

public class AbstractOperation: NSOperation {
    
    enum State {
        case isReady, isExecuting, isFinished
        
        func canTransition(toState state: State) -> Bool {
            switch (self, state) {
            case (.isReady, .isExecuting):      return true
            case (.isReady, .isFinished):       return true
            case (.isExecuting, .isFinished):   return true
            default:                            return false
            }
        }
    }
    
    // use the KVO mechanism to indicate that changes to `state` affect other properties as well
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    // A lock to guard reads and writes to the `_state` property
    private let stateLock = NSLock()
    
    private var _state = State.isReady
    var state: State {
        get {
            stateLock.lock()
            let value = _state
            stateLock.unlock()
            return value
        }
        set (newState) {
            // Note that the KVO notifications MUST NOT be called from inside the lock. If they were, the app would deadlock.
            willChangeValueForKey("state")
            
            stateLock.lock()
            guard _state != .isFinished else { return }
            assert(_state.canTransition(toState: newState), "Performing invalid state transition from \(_state) to \(newState).")
            _state = newState
            stateLock.unlock()
            
            didChangeValueForKey("state")
        }
    }
    
    public override var ready: Bool {
        return state == .isReady ? (super.ready || cancelled) : false
    }
    
    public override var executing: Bool {
        return state == .isExecuting
    }
    
    public override var finished: Bool {
        return state == .isFinished
    }
    
    var hasCancelledDependencies: Bool {
        // Return true if this operation has any dependency (parent) operation that is cancelled
        return dependencies.reduce(false) { $0 || $1.cancelled }
    }
    
    public override init() {
        super.init()
        addObserver(self, forKeyPath: "cancelled", options: [], context: nil)
    }
    
    // Observing `cancelled` status gives us a chance to react to this status in `didCancel` method if necessary
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath == "isCancelled" else { return }
        if cancelled {
            didCancel()
        }
    }

    final public override func start() {
        // If any dependency (parent operation) is cancelled, we should also cancel this operation
        if hasCancelledDependencies {
            finish()
            return
        }
        
        if cancelled {
            finish()
            return
        }
        
        state = .isExecuting
        main()
    }
    
    public override func main() {
        fatalError("This method has to be overriden and has to call `finish()` at some point")
    }

    public func didCancel() {
        finish()
    }

    public func finish() {
        state = .isFinished
    }
    
    deinit {
        removeObserver(self, forKeyPath: "cancelled")
    }
    
}

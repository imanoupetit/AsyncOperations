
import Foundation

/**
 NSOperation documentation:
 Operation objects are synchronous by default.
 At no time in your start method should you ever call super.
 When you add an operation to an operation queue, the queue ignores the value of the asynchronous property and always calls the start method from a separate thread.
 If you are creating a concurrent operation, you need to override the following methods and properties at a minimum:
 start, asynchronous, executing, finished.
 */

open class AbstractOperation: Operation {
    
    @objc enum State: Int {
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
        return [#keyPath(state) as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return [#keyPath(state) as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return [#keyPath(state) as NSObject]
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
            willChangeValue(forKey: #keyPath(state))
            
            stateLock.lock()
            guard _state != .isFinished else { return }
            assert(_state.canTransition(toState: newState), "Performing invalid state transition from \(_state) to \(newState).")
            _state = newState
            stateLock.unlock()
            
            didChangeValue(forKey: #keyPath(state))
        }
    }
    
    override open var isExecuting: Bool {
        return state == .isExecuting
    }
    
    override open var isFinished: Bool {
        return state == .isFinished
    }
    
    var hasCancelledDependencies: Bool {
        // Return true if this operation has any dependency (parent) operation that is cancelled
        return dependencies.reduce(false) { $0 || $1.isCancelled }
    }
    
    public override init() {
        super.init()
        addObserver(self, forKeyPath: #keyPath(isCancelled), options: [], context: nil)
    }

    // Observing `cancelled` status gives us a chance to react to this status in `didCancel` method if necessary
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(isCancelled) else { return }
        if isCancelled {
            didCancel()
        }
    }
    
    override final public func start() {
        // If any dependency (parent operation) is cancelled, we should also cancel this operation
        if hasCancelledDependencies {
            finish()
            return
        }
        
        if isCancelled {
            finish()
            return
        }
        
        state = .isExecuting
        main()
    }
    
    open override func main() {
        fatalError("This method has to be overriden and has to call `finish()` at some point")
    }
    
    open func didCancel() {
        finish()
    }
    
    open func finish() {
        state = .isFinished
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(isCancelled))
    }
    
}

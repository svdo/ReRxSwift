//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

class FakeStore<S: StateType>: Store<S> {
    var subscribers = [AnyStoreSubscriber]()
    
    override open func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        subscribers.append(subscriber)
    }

    override open func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscribers.index(where: { $0 === subscriber }) {
            subscribers.remove(at: index)
        }
    }
}

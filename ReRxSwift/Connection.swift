//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

public class Connection<State: StateType, Props, Actions>: StoreSubscriber {
    let store: Store<State>

    public init(store: Store<State>,
                mapStateToProps: @escaping (State) -> (Props),
                mapDispatchToActions: (@escaping DispatchFunction) -> (Actions)
        ) {
        self.store = store
    }

    public func connect() {
        store.subscribe(self)
    }

    public func disconnect() {
        store.unsubscribe(self)
    }

    public func newState(state: State) {}
}

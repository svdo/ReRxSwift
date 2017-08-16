//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift
import RxSwift

public class Connection<State: StateType, Props, Actions>: StoreSubscriber {
    let store: Store<State>
    let mapStateToProps: (State) -> (Props)
    public let props: Variable<Props>

    public init(store: Store<State>,
                mapStateToProps: @escaping (State) -> (Props),
                mapDispatchToActions: (@escaping DispatchFunction) -> (Actions)
        ) {
        self.store = store
        self.mapStateToProps = mapStateToProps
        let initialState = store.state!
        let props = mapStateToProps(initialState)
        self.props = Variable(props)
    }

    public func connect() {
        store.subscribe(self)
    }

    public func disconnect() {
        store.unsubscribe(self)
    }

    public func newState(state: State) {
        props.value = mapStateToProps(state)
    }
}

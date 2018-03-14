//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReRxSwift
import ReSwift

struct SimpleProps {
    let str: String
}
struct SimpleActions {
    let foo: String
}

let mapStateToProps = { (state: TestState) in
    return SimpleProps(str: state.someString)
}

let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return SimpleActions(foo: "bar")
}

class TestConnectable: Connectable {
    let connection = Connection(
        store: Store<TestState>(
            reducer: {(_,state) in return state!},
            state: initialState),
        mapStateToProps: mapStateToProps,
        mapDispatchToActions: mapDispatchToActions)
}

class ConnectableSpec: QuickSpec {
    override func spec() {
        var connectable: TestConnectable!

        beforeEach {
            connectable = TestConnectable()
        }

        it("gets its props from its connection") {
            let newProps = SimpleProps(str: "new")
            connectable.connection.props.accept(newProps)
            expect(connectable.props.str) == newProps.str
        }

        it("sets its props to its connection") {
            let newProps = SimpleProps(str: "new")
            connectable.props = newProps
            expect(connectable.connection.props.value.str) == newProps.str
        }

        it("gets its actions from its connection") {
            let newActions = SimpleActions(foo: "new")
            connectable.connection.actions = newActions
            expect(connectable.actions.foo) == newActions.foo
        }

        it("sets its actions to its connection") {
            let newActions = SimpleActions(foo: "new")
            connectable.actions = newActions
            expect(connectable.connection.actions.foo) == newActions.foo
        }
    }
}

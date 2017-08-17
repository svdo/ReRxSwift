//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
import UIKit
import RxCocoa

let initialState = TestState(someString: "initial string")

struct ViewControllerProps {
    let foo: String
}
struct ViewControllerActions {
    let setNewString: (String) -> Void
}

class ConnectionSpec: QuickSpec {
    override func spec() {
        var testStore : FakeStore<TestState>! = nil
        let mapStateToProps = { (state: TestState) in
            return ViewControllerProps(foo: state.someString)
        }
        let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
            return ViewControllerActions(
                setNewString: { str in dispatch(TestAction(newString: str)) }
            )
        }
        var connection: Connection<TestState, ViewControllerProps, ViewControllerActions>!

        beforeEach {
            testStore = FakeStore<TestState>(
                reducer: {(_,state) in return state!},
                state: initialState)
            connection = Connection(
                store:testStore,
                mapStateToProps: mapStateToProps,
                mapDispatchToActions: mapDispatchToActions
            )
        }

        it("subscribes to the store when connecting") {
            let connection = Connection(
                store:testStore,
                mapStateToProps: mapStateToProps,
                mapDispatchToActions: mapDispatchToActions
            )
            connection.connect()
            expect(testStore.subscribers).to(haveCount(1))
            expect(testStore.subscribers[0]) === connection
        }

        context("when it is subscribed") {

            beforeEach {
                connection.connect()
            }

            it("unsubscribes from the store when disconnecting") {
                connection.disconnect()
                expect(testStore.subscribers).to(beEmpty())
            }
        }

        it("uses store's initial state for initial props value") {
            expect(connection.props.value.foo) == initialState.someString
        }
        
        it("can set and get props") {
            connection.props.value = ViewControllerProps(foo: "some props")
            expect(connection.props.value.foo) == "some props"
        }

        it("sets new props when receiving new state from ReSwift") {
            let newState = TestState(someString: "new string")
            connection.newState(state: newState)
            expect(connection.props.value.foo) == newState.someString
        }

        it("maps actions using the store's dispatch function") {
            var dispatchedAction: Action? = nil
            testStore.dispatchFunction = { (action:Action) in dispatchedAction = action }

            connection.actions.setNewString("new string")
            expect(dispatchedAction as? TestAction) == TestAction(newString: "new string")
        }

        // binding
        it("can bind a text field's text") {
            let textField = UITextField()
            connection.bind(\ViewControllerProps.foo, to: textField.rx.text)
            connection.newState(state: TestState(someString: "textField.text"))
            expect(textField.text) == "textField.text"
        }
    }
}

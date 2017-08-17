//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
import UIKit
import RxCocoa

let initialState = TestState(someString: "initial string", someFloat: 0.42)

struct ViewControllerProps {
    let str: String
    let flt: Float
}
struct ViewControllerActions {
    let setNewString: (String) -> Void
}

class ConnectionSpec: QuickSpec {
    override func spec() {
        var testStore : FakeStore<TestState>! = nil
        let mapStateToProps = { (state: TestState) in
            return ViewControllerProps(
                str: state.someString,
                flt: state.someFloat
            )
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
            expect(connection.props.value.str) == initialState.someString
        }
        
        it("can set and get props") {
            connection.props.value = ViewControllerProps(str: "some props", flt: 0)
            expect(connection.props.value.str) == "some props"
        }

        it("sets new props when receiving new state from ReSwift") {
            let newState = TestState(someString: "new string", someFloat: 0)
            connection.newState(state: newState)
            expect(connection.props.value.str) == newState.someString
        }

        it("maps actions using the store's dispatch function") {
            var dispatchedAction: Action? = nil
            testStore.dispatchFunction = { (action:Action) in dispatchedAction = action }

            connection.actions.setNewString("new string")
            expect(dispatchedAction as? TestAction) == TestAction(newString: "new string")
        }

        describe("binding") {
            it("can bind an optional observer") {
                let textField = UITextField()
                connection.bind(\ViewControllerProps.str, to: textField.rx.text)
                connection.newState(state: TestState(someString: "textField.text", someFloat: 0.0))
                expect(textField.text) == "textField.text"
            }

            it("can bind an optional observer using additional mapping") {
                let textField = UITextField()
                connection.bind(\ViewControllerProps.flt, to: textField.rx.text, mapping: { String($0) })
                connection.newState(state: TestState(someString: "", someFloat: 42.42))
                expect(textField.text) == "42.42"
            }

            it("can bind a non-optional observer") {
                let progressView = UIProgressView()
                connection.bind(\ViewControllerProps.flt, to: progressView.rx.progress)
                connection.newState(state: TestState(someString: "", someFloat: 0.42))
                expect(progressView.progress) ≈ 0.42
            }

            it("can bind a non-optional observer using additional mapping") {
                let progressView = UIProgressView()
                connection.bind(\ViewControllerProps.str, to: progressView.rx.progress, mapping: { Float($0) ?? 0 })
                connection.newState(state: TestState(someString: "0.42", someFloat: 0))
                expect(progressView.progress) ≈ 0.42
            }
}
    }
}

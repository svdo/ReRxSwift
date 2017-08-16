//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift

let initialState = TestState(someString: "initial string")

class ConnectionSpec: QuickSpec {
    override func spec() {
        var testStore : FakeStore<TestState>! = nil
        let mapStateToProps = { (state: TestState) in
            return TestProps(foo: state.someString)
        }
        let mapDispatchToActions = { (_: DispatchFunction) in
            return TestActions(
                bar: { _ in }
            )
        }
        var connection: Connection<TestState, TestProps, TestActions>!

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
            connection.props.value = TestProps(foo: "some props")
            expect(connection.props.value.foo) == "some props"
        }

        it("sets new props when receiving new state from ReSwift") {
            let newState = TestState(someString: "new string")
            connection.newState(state: newState)
            expect(connection.props.value.foo) == newState.someString
        }
    }
}

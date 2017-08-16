//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift

class ConnectionSpec: QuickSpec {
    override func spec() {
        var testStore : FakeStore<TestState>! = nil

        beforeEach {
            testStore = FakeStore<TestState>(reducer: {(_,_) in return TestState()}, state: nil)
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
            var connection: Connection<TestState, TestProps, TestActions>!

            beforeEach {
                connection = Connection(
                    store:testStore,
                    mapStateToProps: mapStateToProps,
                    mapDispatchToActions: mapDispatchToActions
                )
                connection.connect()
            }

            it("unsubscribes from the store when disconnecting") {
                connection.disconnect()
                expect(testStore.subscribers).to(beEmpty())
            }
        }
    }
}

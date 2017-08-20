//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
import UIKit
import RxCocoa
import RxDataSources

let initialState = TestState(someString: "initial string", someFloat: 0.42, numbers: [])

struct TestSection {
    var header: String
    var items: [Int]
}

extension TestSection: Equatable {
    static func ==(lhs: TestSection, rhs: TestSection) -> Bool {
        return lhs.header == rhs.header && lhs.items == rhs.items
    }
}

extension TestSection: AnimatableSectionModelType {
    var identity: String {
        return header
    }
    init(original: TestSection, items: [Int]) {
        self = original
        self.items = items
    }
}

struct ViewControllerProps {
    let str: String
    let flt: Float
    let sections: [TestSection]
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
                flt: state.someFloat,
                sections: [TestSection(header: "section", items: state.numbers)]
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
            connection.props.value = ViewControllerProps(str: "some props", flt: 0, sections: [])
            expect(connection.props.value.str) == "some props"
        }

        it("sets new props when receiving new state from ReSwift") {
            let newState = TestState(someString: "new string", someFloat: 0, numbers: [])
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
                connection.newState(state: TestState(someString: "textField.text", someFloat: 0.0, numbers: []))
                expect(textField.text) == "textField.text"
            }

            it("can bind an optional observer using additional mapping") {
                let textField = UITextField()
                connection.bind(\ViewControllerProps.flt, to: textField.rx.text, mapping: { String($0) })
                connection.newState(state: TestState(someString: "", someFloat: 42.42, numbers: []))
                expect(textField.text) == "42.42"
            }

            it("can bind a non-optional observer") {
                let progressView = UIProgressView()
                connection.bind(\ViewControllerProps.flt, to: progressView.rx.progress)
                connection.newState(state: TestState(someString: "", someFloat: 0.42, numbers: []))
                expect(progressView.progress) ≈ 0.42
            }

            it("can bind a non-optional observer using additional mapping") {
                let progressView = UIProgressView()
                connection.bind(\ViewControllerProps.str, to: progressView.rx.progress, mapping: { Float($0) ?? 0 })
                connection.newState(state: TestState(someString: "0.42", someFloat: 0, numbers: []))
                expect(progressView.progress) ≈ 0.42
            }

            it("can bind colletion view items") {
                let collectionView = UICollectionView(
                    frame: CGRect(),
                    collectionViewLayout: UICollectionViewFlowLayout())
                let dataSource = RxCollectionViewSectionedReloadDataSource<TestSection>()
                connection.bind(\ViewControllerProps.sections, to: collectionView.rx.items(dataSource: dataSource))
                expect(collectionView.dataSource).toNot(beNil())
                connection.newState(state: TestState(someString: "", someFloat: 0,
                                                     numbers: [12, 34]))
                expect(dataSource.numberOfSections(in: collectionView)) == 1
                expect(dataSource.collectionView(collectionView, numberOfItemsInSection: 0)) == 2
            }
        }
    }
}

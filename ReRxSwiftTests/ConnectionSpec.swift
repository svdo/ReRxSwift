//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
import UIKit
import RxCocoa
import RxDataSources

let initialState = TestState(someString: "initial string", someFloat: 0.42, numbers: [])

struct ViewControllerProps {
    let str: String
    let flt: Float
    let sections: [TestSectionModel]
    let optInt: Int?
}
struct ViewControllerActions {
    let setNewString: (String) -> Void
}

struct DummyAction: Action {}

class ConnectionSpec: QuickSpec {
    override func spec() {
        describe("sub - unsub") {
            var testStore: Store<TestState>!
            var mapStateToPropsCalled: Bool? = nil
            var connection: Connection<TestState, SimpleProps, SimpleActions>!

            beforeEach {
                testStore = Store<TestState>(
                    reducer: {(_,state) in return state!},
                    state: initialState)
                connection = Connection(
                    store: testStore,
                    mapStateToProps: { _ in
                        mapStateToPropsCalled = true
                        return SimpleProps(str: "")
                    },
                    mapDispatchToActions: mapDispatchToActions
                )
                mapStateToPropsCalled = nil
            }

            it("subscribes to the store when connecting") {
                connection.connect()
                testStore.dispatch(DummyAction())
                expect(mapStateToPropsCalled).to(beTrue())
            }

            context("when it is subscribed") {
                beforeEach {
                    connection.connect()
                    mapStateToPropsCalled = nil
                }

                it("unsubscribes from the store when disconnecting") {
                    connection.disconnect()
                    testStore.dispatch(DummyAction())
                    expect(mapStateToPropsCalled).to(beNil())
                }
            }
        }

        context("given a connection") {
            var testStore : FakeStore<TestState>! = nil
            var connection: Connection<TestState, ViewControllerProps, ViewControllerActions>!
            let mapStateToProps = { (state: TestState) in
                return ViewControllerProps(
                    str: state.someString,
                    flt: state.someFloat,
                    sections: state.sections,
                    optInt: state.maybeInt
                )
            }
            let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
                return ViewControllerActions(
                    setNewString: { str in dispatch(TestAction(newString: str)) }
                )
            }

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

            it("uses store's initial state for initial props value") {
                expect(connection.props.value.str) == initialState.someString
            }

            it("can set and get props") {
                connection.props.value = ViewControllerProps(str: "some props", flt: 0, sections: [], optInt: nil)
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

            it("can subscribe to a props entry") {
                var next: String? = nil
                connection.subscribe(\ViewControllerProps.str) { nextStr in
                    next = nextStr
                }
                let newState = TestState(someString: "new string", someFloat: 0, numbers: [])
                connection.newState(state: newState)
                expect(next) == "new string"
            }

            it("can subscribe to an optional props entry") {
                var next: Int? = nil
                connection.subscribe(\ViewControllerProps.optInt) { nextInt in
                    next = nextInt
                }
                let newState = TestState(someString: "", someFloat: 0, numbers: [], maybeInt: 42)
                connection.newState(state: newState)
                expect(next) == 42
            }

            it("can subscribe to an array-typed props entry") {
                var next: [TestSectionModel] = []
                connection.subscribe(\ViewControllerProps.sections) { nextSections in
                    next = nextSections
                }
                let newSection = TestSectionModel(header: "", items: [])
                let newState = TestState(someString: "", someFloat: 0, numbers: [], sections: [newSection])
                connection.newState(state: newState)
                expect(next) == [newSection]
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

                it("it can bind to an optional prop") {
                    let textField = UITextField()
                    connection.bind(\ViewControllerProps.optInt, to: textField.rx.isHidden) { $0 == nil }
                    connection.newState(state: TestState(someString: "", someFloat: 0, numbers: [], maybeInt: nil))
                    expect(textField.isHidden).to(beTrue())
                    connection.newState(state: TestState(someString: "", someFloat: 0, numbers: [], maybeInt: 42))
                    expect(textField.isHidden).to(beFalse())
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
                    let dataSource = RxCollectionViewSectionedReloadDataSource<TestSectionModel>(
                        configureCell: { _,_,_,_ in return UICollectionViewCell() },
                        configureSupplementaryView: { _,_,_,_ in return UICollectionReusableView() })
                    connection.bind(\ViewControllerProps.sections, to: collectionView.rx.items(dataSource: dataSource))
                    expect(collectionView.dataSource).toNot(beNil())
                    connection.newState(state: TestState(someString: "", someFloat: 0,
                                                         numbers: [12, 34],
                                                         sections: [TestSectionModel(header: "section", items: [12,34])]))
                    expect(dataSource.numberOfSections(in: collectionView)) == 1
                    expect(dataSource.collectionView(collectionView, numberOfItemsInSection: 0)) == 2
                }

                it("can bind table view items") {
                    let tableView = UITableView(frame: CGRect(), style: .plain)
                    let dataSource = RxTableViewSectionedReloadDataSource<TestSectionModel>(
                        configureCell: { _,_,_,item in
                            let cell = UITableViewCell()
                            cell.tag = item
                            return cell
                    }
                    )
                    connection.bind(\ViewControllerProps.sections, to: tableView.rx.items(dataSource: dataSource))
                    expect(tableView.dataSource).toNot(beNil())
                    connection.newState(state: TestState(someString: "", someFloat: 0,
                                                         numbers: [12, 34],
                                                         sections: [TestSectionModel(header: "section", items: [12, 34])]))
                    expect(dataSource.numberOfSections(in: tableView)) == 1
                    expect(dataSource.tableView(tableView, numberOfRowsInSection: 0)) == 2
                    expect(tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)).tag) == 12
                    expect(tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)).tag) == 34
                }

                it("can bind table view items with a mapping function") {
                    let tableView = UITableView(frame: CGRect(), style: .plain)
                    let dataSource = RxTableViewSectionedReloadDataSource<TestSectionModel>(
                        configureCell: { _,_,_,item in
                            let cell = UITableViewCell()
                            cell.tag = item
                            return cell
                    }
                    )
                    connection.bind(\ViewControllerProps.sections, to: tableView.rx.items(dataSource: dataSource)) { sections in
                        return sections.map { $0.sorted() }
                    }
                    expect(tableView.dataSource).toNot(beNil())
                    connection.newState(state: TestState(someString: "", someFloat: 0,
                                                         numbers: [12, 34],
                                                         sections: [TestSectionModel(header: "section", items: [34, 12])]))
                    expect(dataSource.numberOfSections(in: tableView)) == 1
                    expect(dataSource.tableView(tableView, numberOfRowsInSection: 0)) == 2
                    expect(tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)).tag) == 12
                    expect(tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)).tag) == 34
                }
            }
        }
    }
}

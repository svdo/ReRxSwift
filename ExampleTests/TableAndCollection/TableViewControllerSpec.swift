//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
@testable import Example

class TableViewControllerSpec: QuickSpec {
    override func spec() {
        var tableViewController: TableViewController!
        var testStore: Store<AppState>!

        beforeEach() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Table")
            guard let table = controller as? TableViewController else {
                fail("Could not load controller from storyboard")
                return
            }
            tableViewController = table
            expect(tableViewController.view).toNot(beNil())

            testStore = Store<AppState>(reducer: testReducer, state: nil)
            tableViewController.connection.store = testStore
        }

        it("has a connection") {
            expect(tableViewController.connection).toNot(beNil())
        }

        it("has props and actions") {
            expect(tableViewController.props).toNot(beNil())
            expect(tableViewController.actions).toNot(beNil())
        }

        describe("table view") {
            it("uses props categories as table view data source") {
                tableViewController.props = TableViewController.Props(
                    categories: [
                        ShopCategory(title: "cat1", description: "cat1desc", shops:[]),
                        ShopCategory(title: "cat2", description: "cat2desc", shops:[]),
                        ShopCategory(title: "cat3", description: "cat3desc", shops: [])
                    ])
                expect(tableViewController.tableView.dataSource?.numberOfSections?(in: tableViewController.tableView)).toEventually(equal(3))
            }
        }

        describe("reverse button") {
            it("triggers action when tapping reverse button") {
                var actionTriggered = false
                tableViewController.actions = TableViewController.Actions(
                    reverse: { actionTriggered = true }
                )
                tableViewController.reverseTapped(tableViewController.reverseButton)
                expect(actionTriggered).to(beTrue())
            }
        }

        describe("map state to props") {
            it("maps categories from state to props") {
                let cats: [ShopCategory] = [
                    ShopCategory(title: "cat1", description: "desc1", shops: [])
                ]
                let state = appState(tableAndCollection:
                    TableAndCollectionState(categories: cats))
                tableViewController.connection.newState(state: state)
                expect(tableViewController.props.categories) == cats
             }
        }

        describe("map dispatch to actions") {
            it("maps reverse action") {
                var dispatchedAction: Action? = nil
                testStore.dispatchFunction = { action in dispatchedAction = action }
                tableViewController.actions.reverse()
                expect(dispatchedAction as? ReverseShops).toNot(beNil())
            }
        }

        context("when viewWillAppear has been called") {
            let cats: [ShopCategory] = [
                ShopCategory(title: "cat1", description: "desc1", shops: [])
            ]

            beforeEach {
                tableViewController.viewWillAppear(false)
            }

            it("is connected") {
                let state = appState(tableAndCollection:
                    TableAndCollectionState(categories: cats))
                testStore.dispatch(ResetState(newState: state))
                expect(tableViewController.tableView.dataSource?.numberOfSections?(in: tableViewController.tableView)).toEventually(equal(1))
            }

            context("when viewDidDisappear has been called") {
                beforeEach {
                    tableViewController.viewDidDisappear(false)
                }

                it("is no longer connected") {
                    let state = appState(tableAndCollection:
                        TableAndCollectionState(categories: cats))
                    testStore.dispatch(ResetState(newState: state))
                    expect(tableViewController.tableView.dataSource?.numberOfSections?(in: tableViewController.tableView)).toEventually(equal(
                        initialTableAndCollectionState.categories.count
                    ))
                }
            }
        }

        it("shows the reverse button") {
            expect(tableViewController.navigationItem.rightBarButtonItem) == tableViewController.reverseButton
        }
    }
}

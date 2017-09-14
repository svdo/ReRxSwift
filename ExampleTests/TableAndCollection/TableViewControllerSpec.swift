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

            testStore = Store<AppState>(reducer: mainReducer, state: nil)
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

    }
}

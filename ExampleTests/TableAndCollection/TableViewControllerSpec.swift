//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
@testable import Example

class TableViewControllerSpec: QuickSpec {
    override func spec() {
        var tableViewController: TableViewController!
//        var testStore: Store<AppState>!

        beforeEach() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Table")
            guard let table = controller as? TableViewController else {
                fail("Could not load controller from storyboard")
                return
            }
            tableViewController = table
            expect(tableViewController.view).toNot(beNil())

//            testStore = Store<AppState>(reducer: mainReducer, state: nil)
//            tableViewController.connection.store = testStore
        }
    }
}

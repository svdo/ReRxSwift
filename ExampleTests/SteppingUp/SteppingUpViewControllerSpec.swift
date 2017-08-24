//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example

class SteppingUpViewControllerSpec: QuickSpec {
    override func spec() {
        it("has a connection") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SteppingUp")
            guard let steppingUpViewController = viewController as? SteppingUpViewController else {
                fail("Failed to load view controller from storyboard")
                return
            }
            expect(steppingUpViewController.view).toNot(beNil())

            expect(steppingUpViewController.connection).toNot(beNil())
        }
    }
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example

class SteppingUpViewControllerSpec: QuickSpec {
    override func spec() {
        var steppingUpViewController: SteppingUpViewController!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SteppingUp")
            guard let steppingUp = viewController as? SteppingUpViewController else {
                fail("Failed to load view controller from storyboard")
                return
            }
            steppingUpViewController = steppingUp
            expect(steppingUpViewController.view).toNot(beNil())
        }

        it("has a connection") {
            expect(steppingUpViewController.connection).toNot(beNil())
        }

        it("has props and actions") {
            expect(steppingUpViewController.props).toNot(beNil())
            expect(steppingUpViewController.actions).toNot(beNil())
        }

        it("uses the props value as slider value") {
            steppingUpViewController.props = SteppingUpViewController.Props(value: 0.4)
            expect(steppingUpViewController.slider.value) ≈ 0.4
        }
    }
}

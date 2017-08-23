//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example
import ReRxSwift

class SimpleTextFieldViewControllerSpec: QuickSpec {
    override func spec() {
        var simpleController: SimpleTextFieldViewController!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SimpleTextField")
            guard let simple = controller as? SimpleTextFieldViewController else {
                fail("Could not load controller from storyboard")
                return
            }
            simpleController = simple
            expect(simpleController.view).toNot(beNil())
        }

        it("takes text field text from props") {
            simpleController.props = SimpleTextFieldViewController.Props(text: "some text")
            expect(simpleController.textField.text) == "some text"
        }

        it("triggers action when editing changes value") {
            var actionTriggered = false
            simpleController.actions = SimpleTextFieldViewController.Actions(
                updatedText: { _ in actionTriggered = true }
            )
            simpleController.editingChanged(simpleController.textField)
            expect(actionTriggered).to(beTrue())
        }
    }
}

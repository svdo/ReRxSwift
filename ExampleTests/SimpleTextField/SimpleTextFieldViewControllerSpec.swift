//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example
import ReRxSwift

class SimpleTextFieldViewControllerSpec: QuickSpec {
    override func spec() {
        var simpleController: SimpleTextFieldViewController!

        beforeEach {
            store.state = initialAppState
            // TODO: create a way to inject the store, because also subscriptions should be reset

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SimpleTextField")
            guard let simple = controller as? SimpleTextFieldViewController else {
                fail("Could not load controller from storyboard")
                return
            }
            simpleController = simple
            expect(simpleController.view).toNot(beNil())
        }

        it("has a connection") {
            expect(simpleController.connection).toNot(beNil())
        }

        it("has props and actions") {
            expect(simpleController.props).toNot(beNil())
            expect(simpleController.actions).toNot(beNil())
        }

        it("uses props text as text field value") {
            simpleController.props = SimpleTextFieldViewController.Props(text: "some text")
            expect(simpleController.textField.text) == "some text"
        }

        it("maps value from state to props") {
            let state = AppState(
                simpleTextField: SimpleTextFieldState(content: "some text"),
                steppingUp: initialSteppingUpState)
            simpleController.connection.newState(state: state)
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

        context("when viewWillAppear has been called") {
            beforeEach {
                simpleController.viewWillAppear(false)
            }

            it("is connected") {
                let state = AppState(
                    simpleTextField: SimpleTextFieldState(content: "test content"),
                    steppingUp: initialSteppingUpState)
                store.state = state
                expect(simpleController.textField.text) == "test content"
            }

            context("when viewDidDisappear has been called") {
                beforeEach {
                    simpleController.viewDidDisappear(false)
                }

                it("is no longer connected") {
                    let state = AppState(
                        simpleTextField: SimpleTextFieldState(content: "test content"),
                        steppingUp: initialSteppingUpState)
                    store.state = state
                    expect(simpleController.textField.text) == initialSimpleTextFieldState.content
                }
            }
        }
    }
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
@testable import Example

class SimpleTextFieldViewControllerSpec: QuickSpec {
    override func spec() {
        var simpleController: SimpleTextFieldViewController!
        var testStore: Store<AppState>!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SimpleTextField")
            guard let simple = controller as? SimpleTextFieldViewController else {
                fail("Could not load controller from storyboard")
                return
            }
            simpleController = simple
            expect(simpleController.view).toNot(beNil())

            testStore = Store<AppState>(reducer: testReducer, state: nil)
            simpleController.connection.store = testStore
        }

        it("has a connection") {
            expect(simpleController.connection).toNot(beNil())
        }

        it("has props and actions") {
            expect(simpleController.props).toNot(beNil())
            expect(simpleController.actions).toNot(beNil())
        }

        context("when viewWillAppear has been called") {
            beforeEach {
                simpleController.viewWillAppear(false)
            }

            it("is connected") {
                let state = appState(simpleTextField: SimpleTextFieldState(content: "test content"))
                testStore.dispatch(ResetState(newState: state))
                expect(simpleController.textField.text) == "test content"
            }

            context("when viewDidDisappear has been called") {
                beforeEach {
                    simpleController.viewDidDisappear(false)
                }

                it("is no longer connected") {
                    let state = appState(simpleTextField: SimpleTextFieldState(content: "test content"))
                    testStore.dispatch(ResetState(newState: state))
                    expect(simpleController.textField.text) == initialSimpleTextFieldState.content
                }
            }
        }

        describe("map state to props") {
            it("maps value from state to props") {
                let state = appState(simpleTextField: SimpleTextFieldState(content: "some text"))
                simpleController.connection.newState(state: state)
                expect(simpleController.props.text) == "some text"
            }
        }

        describe("map dispatch to actions") {
            it("updatedText action") {
                var dispatchedAction: Action? = nil
                testStore.dispatchFunction = { action in dispatchedAction = action }
                simpleController.actions.updatedText("new text")
                expect((dispatchedAction as? SetContent)?.newContent) == "new text"
            }
        }

        describe("text field") {
            it("uses props text as text field value") {
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
}

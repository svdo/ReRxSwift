//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
import ReSwift
import ReRxSwift
@testable import Example

class SteppingUpViewControllerSpec: QuickSpec {
    override func spec() {
        var steppingUpViewController: SteppingUpViewController!
        var testStore: Store<AppState>!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SteppingUp")
            guard let steppingUp = viewController as? SteppingUpViewController else {
                fail("Failed to load view controller from storyboard")
                return
            }
            steppingUpViewController = steppingUp
            expect(steppingUpViewController.view).toNot(beNil())

            testStore = Store<AppState>(reducer: mainReducer, state: nil)
            steppingUpViewController.connection.store = testStore
        }

        it("has a connection") {
            expect(steppingUpViewController.connection).toNot(beNil())
        }

        it("has props and actions") {
            expect(steppingUpViewController.props).toNot(beNil())
            expect(steppingUpViewController.actions).toNot(beNil())
        }

        context("when viewWillAppear has been called") {
            beforeEach {
                steppingUpViewController.viewWillAppear(false)
            }

            it("is connected") {
                let state = AppState(
                    simpleTextField: initialSimpleTextFieldState,
                    steppingUp: SteppingUpState(value: 0.3, stepSize: 0.1))
                testStore.state = state
                expect(steppingUpViewController.slider.value) ≈ 0.3
            }

            context("when viewDidDisappear has been called") {
                beforeEach {
                    steppingUpViewController.viewDidDisappear(false)
                }

                it("is no longer connected") {
                    let state = AppState(
                        simpleTextField: initialSimpleTextFieldState,
                        steppingUp: SteppingUpState(value: 0.3, stepSize: 0.1))
                    testStore.state = state
                    expect(steppingUpViewController.slider.value) ≈ initialSteppingUpState.value
                }
            }
        }

        describe("map state to props") {
            it("value prop") {
                let state = AppState(
                    simpleTextField: initialSimpleTextFieldState,
                    steppingUp: SteppingUpState(value: 0.3, stepSize: 0.1))
                steppingUpViewController.connection.newState(state: state)
                expect(steppingUpViewController.props.value) ≈ 0.3
            }
        }

        describe("map dispatch to actions") {
            it("setValue action") {
                var dispatchedAction: Action? = nil
                testStore.dispatchFunction = { action in dispatchedAction = action }
                steppingUpViewController.actions.setValue(0.42)
                expect((dispatchedAction as? SteppingUpSetValue)?.newValue) ≈ 0.42
            }
        }

        describe("slider") {
            it("uses the props value as slider value") {
                steppingUpViewController.props = SteppingUpViewController.Props(value: 0.4)
                expect(steppingUpViewController.slider.value) ≈ 0.4
            }

            it("changes the value of the state when the slider changes") {
                var value: Float?
                steppingUpViewController.actions = SteppingUpViewController.Actions(
                    setValue: { newValue in value = newValue }
                )
                steppingUpViewController.slider.value = 0.7
                steppingUpViewController.sliderChanged()
                expect(value) ≈ 0.7
            }
        }

        describe("text field") {
            it("uses the props value as text") {
                steppingUpViewController.props = SteppingUpViewController.Props(value: 0.4)
                expect(steppingUpViewController.textField.text) == "0.4"
            }

            it("calls the right action when editing ends") {
                var value: Float?
                steppingUpViewController.actions = SteppingUpViewController.Actions(
                    setValue: { newValue in value = newValue }
                )
                steppingUpViewController.textField.text = "0.6"
                steppingUpViewController.textChanged()
                expect(value) ≈ 0.6
            }
        }
    }
}

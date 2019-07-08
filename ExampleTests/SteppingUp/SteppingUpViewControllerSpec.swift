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

            testStore = Store<AppState>(reducer: testReducer, state: nil)
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
                let state = appState(
                    steppingUp: SteppingUpState(value: 0.3, stepSize: 0.1))
                testStore.dispatch(ResetState(newState: state))
                expect(steppingUpViewController.slider.value) ≈ 0.3
            }

            context("when viewDidDisappear has been called") {
                beforeEach {
                    steppingUpViewController.viewDidDisappear(false)
                }

                it("is no longer connected") {
                    let state = appState(
                        steppingUp: SteppingUpState(value: 0.3, stepSize: 0.1))
                    testStore.dispatch(ResetState(newState: state))
                    expect(steppingUpViewController.slider.value) ≈ initialSteppingUpState.value
                }
            }
        }

        describe("map state to props") {
            it("maps value prop") {
                let state = appState(
                    steppingUp: SteppingUpState(value: 0.3, stepSize: 0.001))
                steppingUpViewController.connection.newState(state: state)
                expect(steppingUpViewController.props.value) ≈ 0.3
            }

            it("maps stepSize prop") {
                let state = appState(
                    steppingUp: SteppingUpState(value: 0, stepSize: 0.11))
                steppingUpViewController.connection.newState(state: state)
                expect(steppingUpViewController.props.stepSize) ≈ 0.11
            }
        }

        describe("map dispatch to actions") {
            it("maps setValue action") {
                var dispatchedAction: Action? = nil
                testStore.dispatchFunction = { action in dispatchedAction = action }
                steppingUpViewController.actions.setValue(0.42)
                expect((dispatchedAction as? SteppingUpSetValue)?.newValue) ≈ 0.42
            }

            it("maps setStepSize action") {
                var dispatchedAction: Action? = nil
                testStore.dispatchFunction = { action in dispatchedAction = action }
                steppingUpViewController.actions.setStepSize(0.24)
                expect((dispatchedAction as? SteppingUpSetStepSize)?.newStepSize) ≈ 0.24
            }
        }

        describe("slider") {
            it("uses the props value as slider value") {
                steppingUpViewController.props = props(value: 0.4)
                expect(steppingUpViewController.slider.value) ≈ 0.4
            }

            it("changes the value of the state when the slider changes") {
                var value: Float?
                steppingUpViewController.actions = actions(
                    setValue: { newValue in value = newValue }
                )
                steppingUpViewController.slider.value = 0.7
                steppingUpViewController.sliderChanged()
                expect(value) ≈ 0.7
            }
        }

        describe("text field") {
            it("uses the props value as text") {
                steppingUpViewController.props = props(value: 0.4)
                expect(steppingUpViewController.textField.text) == "0.4"
            }

            it("calls the right action when editing ends") {
                var value: Float?
                steppingUpViewController.actions = actions(
                    setValue: { newValue in value = newValue }
                )
                steppingUpViewController.textField.text = "0.6"
                steppingUpViewController.textChanged()
                expect(value) ≈ 0.6
            }
        }

        describe("progress view") {
            it("uses the props value as progress") {
                steppingUpViewController.props = props(value: 0.4)
                expect(steppingUpViewController.progressView.progress) ≈ 0.4
            }
        }

        describe("stepper") {
            it("uses the props value as value") {
                steppingUpViewController.props = props(value: 0.4)
                expect(steppingUpViewController.stepper.value) ≈ 0.4
            }

            it("uses the props step size as step size") {
                steppingUpViewController.props = props(stepSize: 0.22)
                expect(steppingUpViewController.stepper.stepValue) ≈ 0.22
            }

            it("calls the right action when value changes") {
                var value: Float?
                steppingUpViewController.actions = actions(
                    setValue: { newValue in value = newValue }
                )
                steppingUpViewController.stepper.value = 0.9
                steppingUpViewController.stepperChanged()
                expect(value) ≈ 0.9
            }
        }

        describe("segmented control") {
            it("uses the props step size for the selected segment") {
                func selectedTitle() -> String? {
                    let index = steppingUpViewController.segmentedControl.selectedSegmentIndex
                    let title = (index >= 0)
                        ? steppingUpViewController.segmentedControl.titleForSegment(at: index)
                        : nil
                    return title
                }
                steppingUpViewController.props = props(stepSize: 0.22)
                expect(selectedTitle()).to(beNil())
                steppingUpViewController.props = props(stepSize: 0.01)
                expect(selectedTitle()) == "0.01"
                steppingUpViewController.props = props(stepSize: 0.1)
                expect(selectedTitle()) == "0.1"
            }

            it("calls the right action when selected segment changes") {
                var stepSize: Float?
                steppingUpViewController.actions = actions(
                    setStepSize: { newStepSize in stepSize = newStepSize }
                )
                steppingUpViewController.segmentedControl.selectedSegmentIndex = 0
                steppingUpViewController.selectedSegmentChanged()
                expect(stepSize) ≈ 0.01
                steppingUpViewController.segmentedControl.selectedSegmentIndex = 1
                steppingUpViewController.selectedSegmentChanged()
                expect(stepSize) ≈ 0.1
                steppingUpViewController.segmentedControl.selectedSegmentIndex = -1
                steppingUpViewController.selectedSegmentChanged()
                expect(stepSize) ≈ 0.1
            }
        }
    }
}

func props(value: Float = 0.0, stepSize: Float = 0.001) -> SteppingUpViewController.Props {
    return SteppingUpViewController.Props(value: value, stepSize: stepSize)
}

func actions(setValue: @escaping (Float)->() = { _ in },
             setStepSize: @escaping (Float)->() = { _ in }
    ) -> SteppingUpViewController.Actions {
    return SteppingUpViewController.Actions(
        setValue: setValue,
        setStepSize: setStepSize
    )
}

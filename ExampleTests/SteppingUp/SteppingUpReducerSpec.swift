//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example

class SteppingUpReducerSpec: QuickSpec {
    override func spec() {
        it("handles setValue") {
            let action = SteppingUpSetValue(newValue: 0.42)
            let nextState = steppingUpReducer(action: action, state: nil)
            expect(nextState.value) ≈ 0.42
        }

        it("handles setStepSize") {
            let action = SteppingUpSetStepSize(newStepSize: 0.42)
            let nextState = steppingUpReducer(action: action, state: nil)
            expect(nextState.stepSize) ≈ 0.42
        }

        it("requires step size greater than zero") {
            let oldStepSize = Float(0.1)
            let state = SteppingUpState(value: 0.5, stepSize: oldStepSize)
            let action = SteppingUpSetStepSize(newStepSize: -0.1)
            let nextState = steppingUpReducer(action: action, state: state)
            expect(nextState.stepSize) == oldStepSize
        }

        it("hanldes increment") {
            let state = SteppingUpState(value: 0.5, stepSize: 0.1)
            let action = SteppingUpIncrement()
            let nextState = steppingUpReducer(action: action, state: state)
            expect(nextState.value) ≈ 0.6
        }

        it("prevents value from being more than 1") {
            let state = SteppingUpState(value: 0.9, stepSize: 0.2)
            let action = SteppingUpIncrement()
            let nextState = steppingUpReducer(action: action, state: state)
            expect(nextState.value) ≈ 1
        }

        it("hanldes decrement") {
            let state = SteppingUpState(value: 0.5, stepSize: 0.1)
            let action = SteppingUpDecrement()
            let nextState = steppingUpReducer(action: action, state: state)
            expect(nextState.value) ≈ 0.4
        }

        it("prevents value from being less than 0") {
            let state = SteppingUpState(value: 0.1, stepSize: 0.2)
            let action = SteppingUpDecrement()
            let nextState = steppingUpReducer(action: action, state: state)
            expect(nextState.value) ≈ 0
        }
    }
}

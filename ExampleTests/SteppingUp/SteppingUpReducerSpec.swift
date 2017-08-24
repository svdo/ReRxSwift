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
    }
}

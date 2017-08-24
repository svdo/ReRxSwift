//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

func steppingUpReducer(action: Action, state: SteppingUpState?) -> SteppingUpState {
    var state = state ?? initialSteppingUpState
    switch action {
    case let setValueAction as SteppingUpSetValue:
        state.value = setValueAction.newValue
    case let setStepSizeAction as SteppingUpSetStepSize:
        state.stepSize = setStepSizeAction.newStepSize
    case _ as SteppingUpIncrement:
        state.value += state.stepSize
        state.value = min(1.0, state.value)
    case _ as SteppingUpDecrement:
        state.value -= state.stepSize
        state.value = max(0.0, state.value)
    default:
        break
    }
    return state
}

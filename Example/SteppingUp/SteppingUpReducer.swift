//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

func steppingUpReducer(action: Action, state: SteppingUpState?) -> SteppingUpState {
    var state = state ?? initialSteppingUpState
    switch action {
    case let setValueAction as SteppingUpSetValue:
        state.value = setValueAction.newValue
    case let setStepSizeAction as SteppingUpSetStepSize:
        state.stepSize = setStepSizeAction.newStepSize
    default:
        break
    }
    return state
}

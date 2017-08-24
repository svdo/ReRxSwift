//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

func steppingUpReducer(action: Action, state: SteppingUpState?) -> SteppingUpState {
    return state ?? initialSteppingUpState
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

func simpleTextFieldReducer(action: Action, state: SimpleTextFieldState?) -> SimpleTextFieldState {
    var state = state ?? initialSimpleTextFieldState
    switch action {
    case let setContentAction as SetContent:
        state.content = setContentAction.newContent
    default:
        break
    }
    return state
}

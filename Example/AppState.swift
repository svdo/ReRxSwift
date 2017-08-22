//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct AppState: StateType, Encodable {
    let simpleTextField: SimpleTextFieldState
}

let initialAppState = AppState(
    simpleTextField: initialSimpleTextFieldState
)


//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct AppState: StateType, Encodable {
    let simpleTextField: SimpleTextFieldState
    let steppingUp: SteppingUpState
    let tableAndCollection: TableAndCollectionState
}

let initialAppState = AppState(
    simpleTextField: initialSimpleTextFieldState,
    steppingUp: initialSteppingUpState,
    tableAndCollection: initialTableAndCollectionState
)

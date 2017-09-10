//  Copyright © 2017 Stefan van den Oord. All rights reserved.

@testable import Example

func appState(
    simpleTextField: SimpleTextFieldState = initialSimpleTextFieldState,
    steppingUp: SteppingUpState = initialSteppingUpState,
    tableAndCollection: TableAndCollectionState = initialTableAndCollectionState
    ) -> AppState {
    return AppState(simpleTextField: simpleTextField,
                    steppingUp: steppingUp,
                    tableAndCollection: tableAndCollection)
}


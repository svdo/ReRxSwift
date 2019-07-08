import ReSwift
@testable import Example

func testReducer(action: Action, state: AppState?) -> AppState {
    if let resetAction = action as? ResetState {
        return resetAction.newState
    }
    return mainReducer(action: action, state: state)
}

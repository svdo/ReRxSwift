//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example

class SimpleTextFieldReducerSpec: QuickSpec {
    override func spec() {
        it("handles SetContent") {
            let action = SetContent(newContent: "foo")
            let state = simpleTextFieldReducer(action: action, state: nil)
            expect(state.content) == "foo"
        }
    }
}

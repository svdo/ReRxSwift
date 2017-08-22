//  Copyright © 2017 Stefan van den Oord. All rights reserved.

struct SimpleTextFieldState: Encodable {
    var content: String
}

let initialSimpleTextFieldState = SimpleTextFieldState(content: "")

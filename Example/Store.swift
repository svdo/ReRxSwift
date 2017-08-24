//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

let store = Store<AppState>(
    reducer: mainReducer,
    state: nil,
    middleware: [ActionLogger()]
)

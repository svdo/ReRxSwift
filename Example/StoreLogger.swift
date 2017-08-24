//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

class StoreLogger: StoreSubscriber {
    let encoder: JSONEncoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
    }

    func newState(state: AppState) {
        do {
            let description = try encoder.encode(state)
            print("State: ", String(data: description, encoding: .utf8)!)
        } catch let e {
            print(e)
        }
    }
}

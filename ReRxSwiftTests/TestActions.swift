//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct TestAction: Action {
    let newString: String
}
extension TestAction: Equatable {
    static func ==(lhs: TestAction, rhs: TestAction) -> Bool {
        return lhs.newString == rhs.newString
    }
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct TestState: StateType {
    let someString: String
    let someFloat: Float
    let numbers: [Int]
    let maybeInt: Int?

    init(someString: String, someFloat: Float, numbers: [Int], maybeInt: Int? = nil) {
        self.someString = someString
        self.someFloat = someFloat
        self.numbers = numbers
        self.maybeInt = maybeInt
    }
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct TestState: StateType {
    let someString: String
    let someFloat: Float
    let numbers: [Int]
    let maybeInt: Int?
    let sections: [TestSectionModel]

    init(someString: String, someFloat: Float, numbers: [Int],
         maybeInt: Int? = nil, sections: [TestSectionModel] = []) {
        self.someString = someString
        self.someFloat = someFloat
        self.numbers = numbers
        self.maybeInt = maybeInt
        self.sections = sections
    }
}

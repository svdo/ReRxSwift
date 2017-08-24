//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Foundation

typealias StepSize = Float

struct SteppingUpState: Encodable {
    var value: Float
    var stepSize: StepSize
}

let initialSteppingUpState = SteppingUpState(value: 0.5, stepSize: 0.1)

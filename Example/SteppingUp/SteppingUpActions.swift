//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

struct SteppingUpIncrement: Action {}

struct SteppingUpDecrement: Action {}

struct SteppingUpSetValue: Action {
    let newValue: Float
}

struct SteppingUpSetStepSize: Action {
    let newStepSize: StepSize
}

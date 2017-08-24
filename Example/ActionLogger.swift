//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

public func ActionLogger<S>() -> Middleware<S> {
    return { dispatch, getState in
        return { next in
            return { action in
                print("Action: ", action)
                return next(action)
            }
        }
    }
}

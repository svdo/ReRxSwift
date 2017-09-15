//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Foundation
import ReSwift

func tableAndCollectionReducer(action: Action, state: TableAndCollectionState?) -> TableAndCollectionState {
    var state = state ?? initialTableAndCollectionState
    switch action {
    case _ as ReverseShops:
        var reversedCategories = [ShopCategory](state.categories.reversed())
        for i in 0 ..< reversedCategories.count {
            reversedCategories[i].shops = reversedCategories[i].shops.reversed()
        }
        state.categories = reversedCategories
    default:
        break
    }
    return state
}

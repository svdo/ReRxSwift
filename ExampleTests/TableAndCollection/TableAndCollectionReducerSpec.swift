//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Quick
import Nimble
@testable import Example

class TableAndControllerSpec: QuickSpec {
    override func spec() {

        let categories: [ShopCategory] = [
            ShopCategory(title: "cat1", description: "desc1", shops: [
                Shop(name: "shop1", rating: 0.1),
                Shop(name: "shop2", rating: 0.2)
            ]),
            ShopCategory(title: "cat2", description: "desc2", shops: [
                Shop(name: "shop3", rating: 0.3),
                Shop(name: "shop4", rating: 0.4)
            ])
        ]

        it("handles Reverse") {
            let initialState = TableAndCollectionState(categories: categories)
            let action = ReverseShops()
            let nextState = tableAndCollectionReducer(action: action, state: initialState)
            expect(nextState.categories.count) == 2
            expect(nextState.categories[0].shops.count) == 2
            expect(nextState.categories[1].shops.count) == 2
            expect(nextState.categories[0].shops[0]) == initialState.categories[1].shops[1]
            expect(nextState.categories[0].shops[1]) == initialState.categories[1].shops[0]
            expect(nextState.categories[1].shops[0]) == initialState.categories[0].shops[1]
            expect(nextState.categories[1].shops[1]) == initialState.categories[0].shops[0]
        }
    }
}

//  Copyright © 2017 Stefan van den Oord. All rights reserved.

struct TableAndCollectionState: Encodable {
    var categories: [Category]
}

struct Category: Encodable {
    var title: String
    var description: String
    var shops: [Shop]
}

struct Shop: Encodable {
    var name: String
    var rating: Float
}

let initialTableAndCollectionState = TableAndCollectionState(
    categories: [
        Category(title: "Food", description: "Restaurants, lunch rooms, bakeries, etc.", shops: [
            Shop(name: "Mario's Pizza", rating: 4.5),
            Shop(name: "Bart's Bakery", rating: 3.0),
            Shop(name: "All You Can Eat", rating: 2.0),
            Shop(name: "The Silver Stalion", rating: 4.5)
        ]),
        Category(title: "Fashion", description: "Men's and women's fashion", shops: [
            Shop(name: "Suits and Stuff", rating: 3.5),
            Shop(name: "Ye Olde Outlet", rating: 2),
            Shop(name: "Wool & Wedding", rating: 4.5)
        ])
    ]
)

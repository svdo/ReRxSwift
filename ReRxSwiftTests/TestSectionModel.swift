//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import RxDataSources

struct TestSectionModel {
    var header: String
    var items: [Int]
}

extension TestSectionModel: Equatable {
    static func ==(lhs: TestSectionModel, rhs: TestSectionModel) -> Bool {
        return lhs.header == rhs.header && lhs.items.elementsEqual(rhs.items)
    }
}

extension TestSectionModel {
    func sorted() -> TestSectionModel {
        return TestSectionModel(header: self.header, items: self.items.sorted())
    }
}

extension TestSectionModel: AnimatableSectionModelType {
    var identity: String {
        return header
    }
    init(original: TestSectionModel, items: [Int]) {
        self = original
        self.items = items
    }
}

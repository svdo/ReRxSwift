//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import UIKit
import ReSwift
import RxSwift
import RxDataSources
import ReRxSwift

private let mapStateToProps = { (appState: AppState) in
    return TableViewController.Props(
        categories: []
    )
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return TableViewController.Actions()
}

extension TableViewController: Connectable {
    struct Props {
        let categories: [ShopCategory]
    }
    struct Actions {}
}

class TableViewController: UITableViewController {
    let connection = Connection(store: store,
                                mapStateToProps: mapStateToProps,
                                mapDispatchToActions: mapDispatchToActions)
    var dataSource: RxTableViewSectionedAnimatedDataSource<ShopCategory>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        dataSource = RxTableViewSectionedAnimatedDataSource<ShopCategory>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
            cell.textLabel?.text = item.name
            return cell
        }
        self.connection.bind(\Props.categories, to: tableView.rx.items(dataSource: dataSource))
    }
}

extension ShopCategory: AnimatableSectionModelType, IdentifiableType {
    public typealias Item = Shop
    public typealias Identity = String

    init(original: ShopCategory, items: [Shop]) {
        self = original
        self.shops = items
    }

    var items: [Shop] { return shops }
    var identity: String { return title }
}

extension ShopCategory: Equatable {
    static func ==(lhs: ShopCategory, rhs: ShopCategory) -> Bool {
        return lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.shops.elementsEqual(rhs.shops)
    }
}

extension Shop: IdentifiableType {
    typealias Identity = String
    var identity: String { return name }
}

extension Shop: Equatable {
    static func ==(lhs: Shop, rhs: Shop) -> Bool {
        return lhs.name == rhs.name && lhs.rating == rhs.rating
    }
}
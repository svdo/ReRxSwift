//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import UIKit
import ReSwift
import RxSwift
import RxDataSources
import ReRxSwift

private let mapStateToProps = { (appState: AppState) in
    return CollectionViewController.Props(
        categories: appState.tableAndCollection.categories
    )
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return CollectionViewController.Actions(reverse: { dispatch(ReverseShops()) })
}

extension CollectionViewController: Connectable {
    struct Props {
        let categories: [ShopCategory]
    }
    struct Actions {
        let reverse: () -> ()
    }
}

class CollectionViewController: UICollectionViewController {
    @IBOutlet var reverseButton: UIBarButtonItem!

    let connection = Connection(store: store,
                                mapStateToProps: mapStateToProps,
                                mapDispatchToActions: mapDispatchToActions)
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<ShopCategory>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.reverseButton
        self.collectionView?.dataSource = nil
        dataSource = RxCollectionViewSectionedAnimatedDataSource<ShopCategory>(configureCell: {
            (dataSource, collectionView, indexPath, item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NormalCell", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = item.name
            (cell.viewWithTag(2) as? UILabel)?.text = String(item.rating)
            return cell
        }, configureSupplementaryView: {
            (dataSource, collectionView, kind, indexPath) in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
            (view.viewWithTag(1) as? UILabel)?.text = self.props.categories[indexPath.section].title
            return view
        })
        self.connection.bind(\Props.categories, to: collectionView!.rx.items(dataSource: dataSource))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connection.connect()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connection.disconnect()
    }

    @IBAction func reverseTapped(_ sender: UIBarButtonItem) {
        actions.reverse()
    }
}

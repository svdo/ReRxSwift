//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import UIKit
import ReSwift
import ReRxSwift

private let mapStateToProps = { (_: AppState) in
    return TableViewController.Props()
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return TableViewController.Actions()
}

extension TableViewController: Connectable {
    struct Props {}
    struct Actions {}
}

class TableViewController: UITableViewController {
    let connection = Connection(store: store,
                                mapStateToProps: mapStateToProps,
                                mapDispatchToActions: mapDispatchToActions)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

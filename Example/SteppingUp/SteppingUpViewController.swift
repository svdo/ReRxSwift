//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Foundation
import UIKit
import ReSwift
import ReRxSwift

class SteppingUpViewController: UIViewController {
    let connection = Connection(store: store,
                                mapStateToProps: mapStateToProps,
                                mapDispatchToActions: mapDispatchToActions)
}

extension SteppingUpViewController: Connectable {
    struct Props {}
    struct Actions {}
}

private let mapStateToProps = { (appState: AppState) in
    return SteppingUpViewController.Props()
}
private let mapDispatchToActions = { (dispatch: DispatchFunction) in
    return SteppingUpViewController.Actions()
}

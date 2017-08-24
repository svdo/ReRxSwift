//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import Foundation
import UIKit
import ReSwift
import RxSwift
import ReRxSwift

class SteppingUpViewController: UIViewController {
    let connection = Connection(store: store,
                                mapStateToProps: mapStateToProps,
                                mapDispatchToActions: mapDispatchToActions)
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        connection.bind(\Props.value, to: slider.rx.value)
    }
}

extension SteppingUpViewController: Connectable {
    struct Props {
        let value: Float
    }
    struct Actions {}
}

private let mapStateToProps = { (appState: AppState) in
    return SteppingUpViewController.Props(value: 0)
}

private let mapDispatchToActions = { (dispatch: DispatchFunction) in
    return SteppingUpViewController.Actions()
}

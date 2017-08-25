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
    @IBOutlet weak var stepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()
        connection.bind(\Props.value, to: slider.rx.value)
        connection.bind(\Props.value, to: textField.rx.text, mapping: { String($0) })
        connection.bind(\Props.value, to: progressView.rx.progress)
        connection.bind(\Props.value, to: stepper.rx.value, mapping: { Double($0) })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connection.connect()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connection.disconnect()
    }
    
    @IBAction func sliderChanged() {
        actions.setValue(slider.value)
    }

    @IBAction func textChanged() {
        guard let text = textField.text, let newValue = Float(text) else {
            return
        }
        actions.setValue(newValue)
    }

    @IBAction func stepperChanged() {
        actions.setValue(Float(stepper.value))
    }
}

extension SteppingUpViewController: Connectable {
    struct Props {
        let value: Float
        let stepSize: Float
    }
    struct Actions {
        let setValue: (Float) -> ()
    }
}

private let mapStateToProps = { (appState: AppState) in
    return SteppingUpViewController.Props(value: appState.steppingUp.value,
                                          stepSize: appState.steppingUp.stepSize)
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return SteppingUpViewController.Actions(
        setValue: { newValue in dispatch(SteppingUpSetValue(newValue: newValue)) }
    )
}

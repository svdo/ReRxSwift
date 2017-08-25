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
        connection.bind(\Props.stepSize, to: segmentedControl.rx.selectedSegmentIndex, mapping: { self.segmentIndex(for: $0) })
    }

    func segmentIndex(for stepSize: Float) -> Int {
        for index in 0 ..< segmentedControl.numberOfSegments {
            guard let title = segmentedControl.titleForSegment(at: index),
                  let segment = Float(title) else {
                continue
            }
            if stepSize == segment {
                return index
            }
        }
        return -1
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
        let setStepSize: (Float) -> ()
    }
}

private let mapStateToProps = { (appState: AppState) in
    return SteppingUpViewController.Props(value: appState.steppingUp.value,
                                          stepSize: appState.steppingUp.stepSize)
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return SteppingUpViewController.Actions(
        setValue: { newValue in dispatch(SteppingUpSetValue(newValue: newValue)) },
        setStepSize: { newStepSize in
            dispatch(SteppingUpSetStepSize(newStepSize: newStepSize))
        }
    )
}

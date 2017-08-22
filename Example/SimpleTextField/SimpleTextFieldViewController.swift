//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import UIKit
import ReSwift
import RxSwift
import ReRxSwift

class SimpleTextFieldViewController: UIViewController {
    let connection = Connection(
        store: store,
        mapStateToProps: mapStateToProps,
        mapDispatchToActions: mapDispatchToActions
    )

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connection.connect()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connection.disconnect()
    }

    override func viewDidLoad() {
        connection.bind(\Props.text, to: textField.rx.text)
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        actions.updatedText(sender.text ?? "")
    }
    
    @IBOutlet weak var textField: UITextField!
}

extension SimpleTextFieldViewController: Connectable {
    struct Props {
        let text: String
    }
    struct Actions {
        let updatedText: (String) -> Void
    }
}

private let mapStateToProps = { (appState: AppState) in
    return SimpleTextFieldViewController.Props(
        text: appState.simpleTextField.content
    )
}

private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
    return SimpleTextFieldViewController.Actions(
        updatedText: { newText in dispatch(SetContent(newContent: newText)) }
    )
}


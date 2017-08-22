//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import UIKit
import ReSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storeLogger = StoreLogger()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        store.subscribe(storeLogger)
        return true
    }
}

class StoreLogger: StoreSubscriber {
    let encoder: JSONEncoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
    }

    func newState(state: AppState) {
        do {
            let description = try encoder.encode(state)
            print("------- new state: ")
            print(String(data: description, encoding: .utf8)!)
        } catch let e {
            print(e)
        }
    }
}

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

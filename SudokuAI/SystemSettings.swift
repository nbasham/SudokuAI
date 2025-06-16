import Foundation
import UIKit

class SystemSettings: NSObject {

    static var prerelease: Bool {
        get { return UserDefaults.getb("prerelease") }
        set { UserDefaults.save(newValue, forKey: "prerelease") }
    }
    
    static var useSound: Bool {
        get { return UserDefaults.getb("useSound") }
        set { UserDefaults.save(newValue, forKey: "useSound") }
    }

    static var showIncorrect: Bool {
        get { return UserDefaults.getb("showIncorrect") }
        set { UserDefaults.save(newValue, forKey: "showIncorrect") }
    }
    
    static var keyboardSwapSides: Bool {
        get { return UserDefaults.getb("keyboardSwapSides") }
        set { UserDefaults.save(newValue, forKey: "keyboardSwapSides") }
    }

    static var showRowColSelector: Bool {
        get { return UserDefaults.getb("showRowColSelector") }
        set { UserDefaults.save(newValue, forKey: "showRowColSelector") }
    }

    static var completeLastNumber: Bool {
        get { return UserDefaults.getb("completeLastNumber") }
        set { UserDefaults.save(newValue, forKey: "completeLastNumber") }
    }

    static var usageTracking: Bool {
        get { return UserDefaults.getb("usageTracking") }
        set { UserDefaults.save(newValue, forKey: "usageTracking") }
    }

    static var useHaptics: Bool {
        get { return UserDefaults.getb("useHaptics") }
        set { UserDefaults.save(newValue, forKey: "useHaptics") }
    }

    static var showTimer: Bool {
        get { return UserDefaults.getb("showTimer") }
        set { UserDefaults.save(newValue, forKey: "showTimer") }
    }

    static func setDefaults() {
        #if DEBUG
            SystemSettings.prerelease = true
        #else
            SystemSettings.prerelease = false
        #endif
        SystemSettings.showRowColSelector = false
        SystemSettings.completeLastNumber = true
        SystemSettings.useSound = true
        SystemSettings.showIncorrect = true
        SystemSettings.keyboardSwapSides = false
        SystemSettings.usageTracking = true
        SystemSettings.useHaptics = true
        SystemSettings.showTimer = false
    }

}

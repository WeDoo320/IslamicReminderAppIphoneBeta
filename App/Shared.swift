import Foundation
import ManagedSettings

enum Shared {
    static let defaults = UserDefaults(suiteName: "group.com.islamicreminder")!
    static let store = ManagedSettingsStore()

    static func lock(prayer: String) {
        store.shield.applicationCategories = .all()
        store.shield.webDomainCategories = .all()
        defaults.set(prayer, forKey: "currentPrayer")
    }

    static func unlock() {
        store.clearAllSettings()
        defaults.removeObject(forKey: "currentPrayer")
    }

    static var currentPrayer: String? { defaults.string(forKey: "currentPrayer") }
}

import SwiftUI
import FamilyControls
import UserNotifications

@main
struct IslamicReminderApp: App {
    @StateObject private var prayers = PrayerManager()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(prayers)
                .task {
                    try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                    prayers.start()
                }
        }
    }
}

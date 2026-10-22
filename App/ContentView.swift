import SwiftUI

struct ContentView: View {
    @EnvironmentObject var prayers: PrayerManager
    @State private var locked = Shared.currentPrayer
    @State private var scanning = false

    var body: some View {
        NavigationStack {
            List {
                if let p = locked {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🔒 Zeit für \(p)").font(.headline)
                            Text("Scanne deine Gebetsmatte, um deine Apps zu entsperren.")
                            Button("Gebetsmatte scannen") { scanning = true }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                Section(prayers.city) {
                    ForEach(prayers.today) { p in
                        HStack {
                            Text(p.id.components(separatedBy: "-")[0])
                            Spacer()
                            Text(p.time, style: .time).monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("Islamic Reminder")
            .refreshable { prayers.start() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                locked = Shared.currentPrayer
            }
            .fullScreenCover(isPresented: $scanning) {
                ScanView {
                    Shared.unlock()
                    locked = nil
                    scanning = false
                }
            }
        }
    }
}

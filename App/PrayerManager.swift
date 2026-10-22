import Foundation
import CoreLocation
import Adhan
import DeviceActivity
import UserNotifications

struct Prayer: Identifiable { let id: String; let time: Date }

final class PrayerManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var today: [Prayer] = []
    @Published var city = "Standort wird ermittelt…"
    private let location = CLLocationManager()

    func start() {
        location.delegate = self
        location.requestWhenInUseAuthorization()
        location.requestLocation()
    }

    func locationManager(_ m: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.last else { return }
        CLGeocoder().reverseGeocodeLocation(loc) { p, _ in
            DispatchQueue.main.async { self.city = p?.first?.locality ?? "Unbekannt" }
        }
        let coords = Coordinates(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        var params = CalculationMethod.muslimWorldLeague.params
        params.madhab = .shafi
        let cal = Calendar.current
        var all: [Prayer] = []
        for offset in 0...1 {   // heute + morgen (max. 20 Monitore erlaubt)
            let day = cal.date(byAdding: .day, value: offset, to: Date())!
            guard let t = PrayerTimes(coordinates: coords,
                                      date: cal.dateComponents([.year, .month, .day], from: day),
                                      calculationParameters: params) else { continue }
            all += [("Fajr", t.fajr), ("Dhuhr", t.dhuhr), ("Asr", t.asr),
                    ("Maghrib", t.maghrib), ("Isha", t.isha)]
                .map { Prayer(id: "\($0.0)-\(offset)", time: $0.1) }
        }
        DispatchQueue.main.async { self.today = Array(all.prefix(5)) }
        schedule(all.filter { $0.time > Date() })
    }

    func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { self.city = "Standort nicht verfügbar" }
    }

    private func schedule(_ prayers: [Prayer]) {
        let center = DeviceActivityCenter()
        center.stopMonitoring()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let cal = Calendar.current
        let comps: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        for p in prayers {
            let name = String(p.id.split(separator: "-")[0])
            // Sperre: Intervall muss mind. 15 Min. lang sein
            let schedule = DeviceActivitySchedule(
                intervalStart: cal.dateComponents(comps, from: p.time),
                intervalEnd: cal.dateComponents(comps, from: p.time.addingTimeInterval(30 * 60)),
                repeats: false)
            try? center.startMonitoring(DeviceActivityName(name + "|" + p.id), during: schedule)

            let content = UNMutableNotificationContent()
            content.title = "\(name) hat begonnen 🕌"
            content.body = "Deine Apps sind gesperrt. Scanne deine Gebetsmatte zum Entsperren."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: cal.dateComponents(comps, from: p.time), repeats: false)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: p.id, content: content, trigger: trigger))
        }
    }
}

import DeviceActivity

/// Wird vom System zur Gebetszeit gestartet – auch wenn die App geschlossen ist.
final class MonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        Shared.lock(prayer: String(activity.rawValue.split(separator: "|")[0]))
    }
    // Kein Entsperren bei intervalDidEnd – nur der Matten-Scan entsperrt.
}

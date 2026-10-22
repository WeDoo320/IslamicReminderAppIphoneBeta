# Islamic Reminder (iOS 16+)

## Bauen (Mac mit Xcode 15+)
    brew install xcodegen
    xcodegen
    open IslamicReminder.xcodeproj
Team unter "Signing" für alle 3 Targets setzen, iPhone anschließen, Run.

## Funktionsweise
- Standort → Gebetszeiten (Adhan, Muslim World League) für heute + morgen
- Zu jedem Gebet: Benachrichtigung + DeviceActivity-Monitor, der alle Apps sperrt (Screen Time API)
- Entsperren nur in der App per Kamera-Scan der Gebetsmatte (Apple Vision)
- App 1× täglich öffnen, damit die Zeiten neu geplant werden

## Wichtig
- Screen-Time-Entitlement `com.apple.developer.family-controls` muss für den App Store bei Apple beantragt werden (für Entwicklung auf eigenem Gerät funktioniert es so).
- Für zuverlässigere Erkennung eigene Matten-Fotos mit Create ML trainieren und `VNClassifyImageRequest` durch das Modell ersetzen.

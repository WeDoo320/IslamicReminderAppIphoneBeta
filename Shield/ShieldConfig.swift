import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Eigener Sperrbildschirm für gesperrte Apps.
final class ShieldConfig: ShieldConfigurationDataSource {
    private var config: ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            icon: UIImage(systemName: "moon.stars.fill"),
            title: .init(text: "Zeit zu beten 🕌", color: .white),
            subtitle: .init(text: "Öffne Islamic Reminder und scanne deine Gebetsmatte.", color: .white),
            primaryButtonLabel: .init(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemGreen)
    }
    override func configuration(shielding application: Application) -> ShieldConfiguration { config }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { config }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { config }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { config }
}

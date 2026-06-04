import SwiftData
import SwiftUI

@main
struct WarmapApp: App {
    @StateObject private var lockManager = AppLockManager()
    @StateObject private var privacyShield = PrivacyShield()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(lockManager)
                .environmentObject(privacyShield)
                .task {
                    FileProtectionService.protectApplicationSupport()
                }
        }
        .modelContainer(for: [Person.self, Encounter.self])
    }
}

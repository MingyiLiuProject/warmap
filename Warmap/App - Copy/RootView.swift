import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var lockManager: AppLockManager
    @EnvironmentObject private var privacyShield: PrivacyShield

    var body: some View {
        ZStack {
            MainTabView()

            if lockManager.isLocked {
                LockView()
                    .transition(.opacity)
            }

            if privacyShield.shouldObscure {
                PrivacyCoverView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.36, dampingFraction: 0.88), value: lockManager.isLocked)
        .animation(.easeInOut(duration: 0.2), value: privacyShield.shouldObscure)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                lockManager.lock()
            } else {
                Task { await lockManager.unlock() }
            }
        }
    }
}

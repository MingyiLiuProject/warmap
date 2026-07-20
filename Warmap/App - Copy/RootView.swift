import SwiftUI

struct RootView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var lockManager: AppLockManager
    @EnvironmentObject private var privacyShield: PrivacyShield

    var body: some View {
        ZStack {
            MainTabView()

            if lockManager.isLocked {
                LockView()
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .scale(scale: 0.985).combined(with: .opacity)
                    )
            }

            if privacyShield.shouldObscure {
                PrivacyCoverView()
                    .transition(
                        .asymmetric(insertion: .identity, removal: .opacity)
                    )
            }
        }
        .preferredColorScheme(.dark)
        .animation(
            WarmapMotion.animation(reduceMotion: reduceMotion),
            value: lockManager.isLocked
        )
        .animation(.easeOut(duration: 0.16), value: privacyShield.shouldObscure)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                lockManager.lock()
            } else {
                Task { await lockManager.unlock() }
            }
        }
    }
}

import SwiftUI

struct LockView: View {
    @EnvironmentObject private var lockManager: AppLockManager

    var body: some View {
        ZStack {
            WarmapBackground()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(WarmapTheme.coral.opacity(0.12))
                        .frame(width: 150, height: 150)
                        .blur(radius: 12)

                    WarmapBrandMark(size: 82)
                }

                VStack(spacing: 10) {
                    Text("WARMAP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(WarmapTheme.coralSoft)

                    Text("只属于你的记录")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(WarmapTheme.textPrimary)

                    Text("没有账号，没有云端，也不会留下预览。")
                        .font(.subheadline)
                        .foregroundStyle(WarmapTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 26)

                Spacer()

                Button {
                    Task { await lockManager.unlock() }
                } label: {
                    Label("验证并解锁", systemImage: "faceid")
                }
                .buttonStyle(WarmapPrimaryButtonStyle())

                if let message = lockManager.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(WarmapTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                }

                WarmapPrivacyPill(text: "端到端本机保护")
                    .padding(.top, 22)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 28)
        }
        .task { await lockManager.unlock() }
    }
}

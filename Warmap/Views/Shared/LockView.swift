import SwiftUI

struct LockView: View {
    @EnvironmentObject private var lockManager: AppLockManager

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.indigo)

                VStack(spacing: 8) {
                    Text("Warmap 已锁定")
                        .font(.title2.bold())
                    Text("验证后查看本机记录")
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task { await lockManager.unlock() }
                } label: {
                    Label("解锁", systemImage: "faceid")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 44)

                if let message = lockManager.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
        .task { await lockManager.unlock() }
    }
}


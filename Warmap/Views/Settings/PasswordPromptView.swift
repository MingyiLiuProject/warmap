import SwiftUI

struct PasswordPromptView: View {
    enum Mode: Equatable {
        case export
        case importBackup

        var title: String {
            switch self {
            case .export: return "加密新备份"
            case .importBackup: return "解锁备份"
            }
        }

        var subtitle: String {
            switch self {
            case .export: return "为这份本地文件设置独立密码"
            case .importBackup: return "密码只在这台设备上用于解密"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    let onSubmit: (String) -> Void

    @State private var password = ""
    @State private var confirmation = ""

    private var canSubmit: Bool {
        guard password.count >= 8 else { return false }
        return mode == .importBackup || password == confirmation
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmapBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        HStack {
                            WarmapIconButton(
                                systemName: "xmark",
                                accessibilityLabel: "取消"
                            ) {
                                dismiss()
                            }
                            Spacer()
                        }

                        ZStack {
                            Circle()
                                .fill(WarmapTheme.coralSurface)
                                .frame(width: 92, height: 92)
                            Image(systemName: mode == .export ? "lock.doc.fill" : "key.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(WarmapTheme.coralSoft)
                        }

                        VStack(spacing: 7) {
                            Text(mode.title)
                                .font(.title2.bold())
                                .foregroundStyle(WarmapTheme.textPrimary)
                            Text(mode.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(WarmapTheme.textSecondary)
                        }

                        WarmapCard {
                            VStack(spacing: 15) {
                                SecureField("密码，至少 8 个字符", text: $password)
                                    .textContentType(.password)
                                    .foregroundStyle(WarmapTheme.textPrimary)

                                if mode == .export {
                                    WarmapDivider()
                                    SecureField("再次输入密码", text: $confirmation)
                                        .textContentType(.newPassword)
                                        .foregroundStyle(WarmapTheme.textPrimary)
                                }
                            }
                        }

                        if mode == .export && !confirmation.isEmpty && password != confirmation {
                            Label("两次输入的密码不一致", systemImage: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(WarmapTheme.coralSoft)
                        }

                        WarmapCard {
                            Label(
                                mode == .export
                                    ? "密码无法找回。请将它保存在可信的密码管理器中。"
                                    : "解密过程完全在本机完成，密码不会被上传。",
                                systemImage: "shield.fill"
                            )
                            .font(.subheadline)
                            .foregroundStyle(WarmapTheme.textSecondary)
                        }

                        Button(mode == .export ? "创建加密备份" : "解密并导入") {
                            onSubmit(password)
                            dismiss()
                        }
                        .buttonStyle(WarmapPrimaryButtonStyle())
                        .disabled(!canSubmit)
                        .opacity(canSubmit ? 1 : 0.45)
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
    }
}

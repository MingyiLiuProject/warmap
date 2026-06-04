import SwiftUI

struct PasswordPromptView: View {
    enum Mode: Equatable {
        case export
        case importBackup

        var title: String {
            switch self {
            case .export: return "设置备份密码"
            case .importBackup: return "输入备份密码"
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
            Form {
                Section {
                    SecureField("密码，至少 8 个字符", text: $password)
                    if mode == .export {
                        SecureField("再次输入密码", text: $confirmation)
                    }
                }

                Section {
                    Text(
                        mode == .export
                            ? "密码无法找回。请使用独立且可靠的密码保存此备份。"
                            : "解密仅在本机进行，密码不会离开设备。"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("继续") {
                        onSubmit(password)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

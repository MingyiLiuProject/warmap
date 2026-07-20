import SwiftData
import SwiftUI

struct PersonEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let person: Person?
    @State private var nickname: String
    @State private var tagsText: String

    init(person: Person? = nil) {
        self.person = person
        _nickname = State(initialValue: person?.nickname ?? "")
        _tagsText = State(initialValue: person?.tagsText ?? "")
    }

    var body: some View {
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

                        Text(person == nil ? "新增人物" : "编辑人物")
                            .font(.headline)
                            .foregroundStyle(WarmapTheme.textPrimary)

                        Spacer()

                        WarmapIconButton(
                            systemName: "checkmark",
                            accessibilityLabel: "保存",
                            prominent: true
                        ) {
                            save()
                        }
                    }

                    WarmapAvatar(
                        name: nickname.isEmpty ? "?" : nickname,
                        seed: person?.id.uuidString ?? nickname,
                        size: 92
                    )
                    .padding(.vertical, 8)

                    WarmapFormSection("匿名身份", systemName: "person.fill") {
                        VStack(spacing: 15) {
                            TextField("昵称或代号", text: $nickname)
                                .font(.title3.bold())
                                .foregroundStyle(WarmapTheme.textPrimary)

                            WarmapDivider()

                            TextField("标签，用逗号分隔", text: $tagsText)
                                .foregroundStyle(WarmapTheme.textPrimary)
                        }
                    }

                    WarmapCard {
                        Label(
                            "建议使用你能识别的代号，不填写真实姓名、电话或社交账号。",
                            systemImage: "shield.lefthalf.filled"
                        )
                        .font(.subheadline)
                        .foregroundStyle(WarmapTheme.textSecondary)
                    }

                    Button("保存人物卡片", action: save)
                        .buttonStyle(WarmapPrimaryButtonStyle())
                        .disabled(
                            nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                        .opacity(
                            nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? 0.45
                                : 1
                        )
                }
                .padding(20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func save() {
        let cleanName = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }

        if let person {
            person.nickname = cleanName
            person.tagsText = tagsText
        } else {
            modelContext.insert(Person(nickname: cleanName, tagsText: tagsText))
        }
        WarmapHaptics.success()
        dismiss()
    }
}

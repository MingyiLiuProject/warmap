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
        Form {
            Section("人物卡片") {
                TextField("昵称或代号", text: $nickname)
                TextField("标签，用逗号分隔", text: $tagsText)
            }

            Section {
                Text("建议只使用你能识别的代号，不填写真实姓名或联系方式。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(person == nil ? "新增人物" : "编辑人物")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存", action: save)
                    .disabled(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let cleanName = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if let person {
            person.nickname = cleanName
            person.tagsText = tagsText
        } else {
            modelContext.insert(Person(nickname: cleanName, tagsText: tagsText))
        }
        dismiss()
    }
}


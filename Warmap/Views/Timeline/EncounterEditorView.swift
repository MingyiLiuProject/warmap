import SwiftData
import SwiftUI

struct EncounterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.nickname) private var people: [Person]

    private let encounter: Encounter?
    @State private var occurredAt: Date
    @State private var selectedPersonID: UUID?
    @State private var placeName: String
    @State private var latitudeText: String
    @State private var longitudeText: String
    @State private var rating: Int
    @State private var tagsText: String
    @State private var notes: String

    init(encounter: Encounter? = nil) {
        self.encounter = encounter
        _occurredAt = State(initialValue: encounter?.occurredAt ?? .now)
        _selectedPersonID = State(initialValue: encounter?.person?.id)
        _placeName = State(initialValue: encounter?.placeName ?? "")
        _latitudeText = State(initialValue: encounter?.latitude.map(String.init) ?? "")
        _longitudeText = State(initialValue: encounter?.longitude.map(String.init) ?? "")
        _rating = State(initialValue: encounter?.rating ?? 5)
        _tagsText = State(initialValue: encounter?.tagsText ?? "")
        _notes = State(initialValue: encounter?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("基本信息") {
                DatePicker("时间", selection: $occurredAt)
                Picker("人物", selection: $selectedPersonID) {
                    Text("未指定").tag(nil as UUID?)
                    ForEach(people) { person in
                        Text(person.nickname).tag(person.id as UUID?)
                    }
                }
                TextField("地点名称", text: $placeName)
            }

            Section("体验评分") {
                RatingView(rating: $rating)
                    .padding(.vertical, 4)
            }

            Section("标签") {
                TextField("用逗号分隔，例如：长期, 周末", text: $tagsText)
            }

            Section("地图坐标（可选）") {
                TextField("纬度", text: $latitudeText)
                    .keyboardType(.numbersAndPunctuation)
                TextField("经度", text: $longitudeText)
                    .keyboardType(.numbersAndPunctuation)
                Text("地图默认只显示模糊坐标，降低精确位置暴露风险。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("备注") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(encounter == nil ? "新增记录" : "编辑记录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存", action: save)
            }
        }
    }

    private func save() {
        let person = people.first { $0.id == selectedPersonID }
        let latitude = Double(latitudeText)
        let longitude = Double(longitudeText)

        if let encounter {
            encounter.occurredAt = occurredAt
            encounter.person = person
            encounter.placeName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
            encounter.latitude = latitude
            encounter.longitude = longitude
            encounter.rating = rating
            encounter.tagsText = tagsText
            encounter.notes = notes
            encounter.updatedAt = .now
        } else {
            modelContext.insert(
                Encounter(
                    occurredAt: occurredAt,
                    placeName: placeName.trimmingCharacters(in: .whitespacesAndNewlines),
                    latitude: latitude,
                    longitude: longitude,
                    rating: rating,
                    tagsText: tagsText,
                    notes: notes,
                    person: person
                )
            )
        }
        dismiss()
    }
}


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
    @State private var showingDeleteConfirmation = false

    init(encounter: Encounter? = nil) {
        self.encounter = encounter
        _occurredAt = State(initialValue: encounter?.occurredAt ?? .now)
        _selectedPersonID = State(initialValue: encounter?.person?.id)
        _placeName = State(initialValue: encounter?.placeName ?? "")
        _latitudeText = State(initialValue: encounter?.latitude.map { String($0) } ?? "")
        _longitudeText = State(initialValue: encounter?.longitude.map { String($0) } ?? "")
        _rating = State(initialValue: encounter?.rating ?? 5)
        _tagsText = State(initialValue: encounter?.tagsText ?? "")
        _notes = State(initialValue: encounter?.notes ?? "")
    }

    var body: some View {
        ZStack {
            WarmapBackground()

            ScrollView {
                VStack(spacing: 22) {
                    header

                    WarmapFormSection("基本信息", systemName: "calendar") {
                        VStack(spacing: 15) {
                            DatePicker("时间", selection: $occurredAt)
                                .tint(WarmapTheme.coralSoft)

                            WarmapDivider()

                            Picker("人物", selection: $selectedPersonID) {
                                Text("未指定").tag(nil as UUID?)
                                ForEach(people) { person in
                                    Text(person.nickname).tag(person.id as UUID?)
                                }
                            }
                            .tint(WarmapTheme.coralSoft)

                            WarmapDivider()

                            HStack {
                                Text("地点")
                                Spacer()
                                TextField("输入地点名称", text: $placeName)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .foregroundStyle(WarmapTheme.textPrimary)
                    }

                    WarmapFormSection(
                        "体验评分",
                        systemName: "star.fill",
                        detail: scoreDescription
                    ) {
                        VStack(spacing: 16) {
                            RatingView(rating: $rating)
                                .frame(maxWidth: .infinity)

                            Text("评分只服务于你的回顾，不代表任何人的价值。")
                                .font(.caption)
                                .foregroundStyle(WarmapTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    WarmapFormSection("标签", systemName: "number") {
                        TextField("例如：长期, 周末, 特别", text: $tagsText)
                            .foregroundStyle(WarmapTheme.textPrimary)
                    }

                    WarmapFormSection(
                        "地图位置",
                        systemName: "location.fill",
                        detail: "可选 · 默认模糊"
                    ) {
                        VStack(spacing: 14) {
                            HStack(spacing: 12) {
                                coordinateField("纬度", text: $latitudeText)
                                coordinateField("经度", text: $longitudeText)
                            }

                            Label(
                                "地图仅展示约公里级的模糊位置",
                                systemImage: "eye.slash.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(WarmapTheme.mint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    WarmapFormSection("私人备注", systemName: "text.alignleft") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(WarmapTheme.textPrimary)
                            .overlay(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("写下只对自己有意义的细节…")
                                        .foregroundStyle(WarmapTheme.textSecondary)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    Button {
                        save()
                    } label: {
                        Label("保存到本机", systemImage: "lock.fill")
                    }
                    .buttonStyle(WarmapPrimaryButtonStyle())

                    if encounter != nil {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("删除这条记录", systemImage: "trash")
                        }
                        .buttonStyle(WarmapSecondaryButtonStyle())
                        .foregroundStyle(WarmapTheme.coralSoft)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "确定删除这条记录？",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive, action: delete)
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销。")
        }
    }

    private var header: some View {
        HStack {
            WarmapIconButton(
                systemName: "xmark",
                accessibilityLabel: "取消"
            ) {
                dismiss()
            }

            Spacer()

            VStack(spacing: 3) {
                Text(encounter == nil ? "新增时刻" : "编辑时刻")
                    .font(.headline)
                    .foregroundStyle(WarmapTheme.textPrimary)
                Text("仅保存在此设备")
                    .font(.caption)
                    .foregroundStyle(WarmapTheme.textSecondary)
            }

            Spacer()

            WarmapIconButton(
                systemName: "checkmark",
                accessibilityLabel: "保存",
                prominent: true
            ) {
                save()
            }
        }
    }

    private var scoreDescription: String {
        switch rating {
        case 1: return "不太好"
        case 2: return "一般"
        case 3: return "不错"
        case 4: return "很好"
        default: return "难忘"
        }
    }

    private func coordinateField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption)
                .foregroundStyle(WarmapTheme.textSecondary)
            TextField("—", text: text)
                .keyboardType(.numbersAndPunctuation)
                .foregroundStyle(WarmapTheme.textPrimary)
        }
        .padding(13)
        .background(WarmapTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
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

    private func delete() {
        guard let encounter else { return }
        modelContext.delete(encounter)
        dismiss()
    }
}

import SwiftData
import SwiftUI

struct PersonDetailView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let person: Person
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    private var sortedEncounters: [Encounter] {
        person.encounters.sorted { $0.occurredAt > $1.occurredAt }
    }

    var body: some View {
        ZStack {
            WarmapBackground()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    identityCard

                    if !person.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            WarmapSectionTitle(title: "标签")
                            ScrollView(.horizontal) {
                                HStack(spacing: 8) {
                                    ForEach(person.tags, id: \.self) { tag in
                                        WarmapTag(text: "#\(tag)")
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }

                    VStack(spacing: 14) {
                        WarmapSectionTitle(
                            title: "共同记录",
                            detail: "\(sortedEncounters.count) 条"
                        )

                        if sortedEncounters.isEmpty {
                            WarmapCard {
                                WarmapEmptyState(
                                    systemName: "sparkles",
                                    title: "还没有共同记录",
                                    message: "新建记录时选择这个代号即可关联。"
                                )
                            }
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(sortedEncounters) { encounter in
                                    NavigationLink {
                                        EncounterEditorView(encounter: encounter)
                                    } label: {
                                        EncounterRow(encounter: encounter)
                                    }
                                    .buttonStyle(WarmapPressButtonStyle())
                                }
                            }
                            .transition(
                                WarmapMotion.transition(reduceMotion: reduceMotion)
                            )
                        }
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("删除人物卡片", systemImage: "trash")
                    }
                    .buttonStyle(WarmapSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEdit) {
            NavigationStack { PersonEditorView(person: person) }
        }
        .confirmationDialog(
            "确定删除人物卡片？",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive, action: delete)
            Button("取消", role: .cancel) {}
        } message: {
            Text("关联记录会被保留，但人物信息会变为未指定。")
        }
    }

    private var header: some View {
        HStack {
            WarmapIconButton(
                systemName: "chevron.left",
                accessibilityLabel: "返回"
            ) {
                dismiss()
            }

            Spacer()
            WarmapPrivacyPill(text: "匿名代号")
            Spacer()

            WarmapIconButton(
                systemName: "pencil",
                accessibilityLabel: "编辑人物"
            ) {
                showingEdit = true
            }
        }
    }

    private var identityCard: some View {
        WarmapCard {
            VStack(spacing: 20) {
                WarmapAvatar(
                    name: person.nickname,
                    seed: person.id.uuidString,
                    size: 88
                )

                VStack(spacing: 5) {
                    Text(person.nickname)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(WarmapTheme.textPrimary)
                    Text("创建于 \(person.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }

                WarmapDivider()

                HStack {
                    WarmapMetric(value: "\(person.encounters.count)", label: "共同记录")
                    Spacer()
                    WarmapMetric(
                        value: person.averageRating?.formatted(
                            .number.precision(.fractionLength(1))
                        ) ?? "—",
                        label: "平均体验",
                        tint: WarmapTheme.gold
                    )
                }
            }
        }
    }

    private func delete() {
        modelContext.delete(person)
        WarmapHaptics.warning()
        dismiss()
    }
}

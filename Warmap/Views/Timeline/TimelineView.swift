import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Encounter.occurredAt, order: .reverse) private var encounters: [Encounter]

    @State private var searchText = ""
    @State private var selectedPersonID: UUID?
    @State private var minimumRating = 1
    @State private var useDateRange = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate = Date.now
    @State private var showingFilters = false
    @State private var showingNewEntry = false

    private var filteredEncounters: [Encounter] {
        encounters.filter { encounter in
            let searchMatches = searchText.isEmpty
                || encounter.placeName.localizedCaseInsensitiveContains(searchText)
                || encounter.person?.nickname.localizedCaseInsensitiveContains(searchText) == true
                || encounter.tagsText.localizedCaseInsensitiveContains(searchText)
            let personMatches = selectedPersonID == nil || encounter.person?.id == selectedPersonID
            let dateMatches = !useDateRange
                || (encounter.occurredAt >= startDate && encounter.occurredAt <= endDate)
            return searchMatches && personMatches && dateMatches && encounter.rating >= minimumRating
        }
    }

    private var averageRating: Double {
        guard !encounters.isEmpty else { return 0 }
        return Double(encounters.map(\.rating).reduce(0, +)) / Double(encounters.count)
    }

    private var peopleCount: Int {
        Set(encounters.compactMap { $0.person?.id }).count
    }

    private var activeFilterCount: Int {
        (selectedPersonID == nil ? 0 : 1)
            + (minimumRating == 1 ? 0 : 1)
            + (useDateRange ? 1 : 0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmapBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        WarmapPageHeader(
                            eyebrow: "Warmap / Private",
                            title: "私人时间线",
                            subtitle: "回望发生过的，也保留只属于你的部分。"
                        ) {
                            WarmapIconButton(
                                systemName: "plus",
                                accessibilityLabel: "新增记录",
                                prominent: true
                            ) {
                                showingNewEntry = true
                            }
                        }

                        TimelineHeroCard(
                            count: encounters.count,
                            peopleCount: peopleCount,
                            averageRating: averageRating
                        )

                        VStack(spacing: 12) {
                            WarmapSearchField(
                                text: $searchText,
                                prompt: "搜索人物、地点或标签"
                            )

                            HStack {
                                Button {
                                    showingFilters = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "slider.horizontal.3")
                                        Text("筛选")
                                        if activeFilterCount > 0 {
                                            Text("\(activeFilterCount)")
                                                .font(.caption2.bold())
                                                .foregroundStyle(WarmapTheme.canvas)
                                                .frame(width: 20, height: 20)
                                                .background(WarmapTheme.coralSoft, in: Circle())
                                                .contentTransition(
                                                    reduceMotion ? .opacity : .numericText()
                                                )
                                        }
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(WarmapTheme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .frame(height: 42)
                                    .background(WarmapTheme.surface, in: Capsule())
                                    .overlay {
                                        Capsule().stroke(WarmapTheme.hairline, lineWidth: 1)
                                    }
                                }
                                .buttonStyle(WarmapPressButtonStyle(pressedScale: 0.96))

                                Spacer()

                                WarmapPrivacyPill()
                            }
                        }

                        if encounters.isEmpty {
                            WarmapCard {
                                WarmapEmptyState(
                                    systemName: "sparkles",
                                    title: "从一个时刻开始",
                                    message: "创建第一条记录。人物、地点和感受都只保存在这台设备上。",
                                    actionTitle: "写下第一条"
                                ) {
                                    showingNewEntry = true
                                }
                            }
                            .transition(
                                WarmapMotion.transition(reduceMotion: reduceMotion)
                            )
                        } else if filteredEncounters.isEmpty {
                            WarmapCard {
                                WarmapEmptyState(
                                    systemName: "line.3.horizontal.decrease.circle",
                                    title: "没有符合条件的记录",
                                    message: "换个关键词，或者放宽筛选条件。"
                                )
                            }
                            .transition(
                                WarmapMotion.transition(reduceMotion: reduceMotion)
                            )
                        } else {
                            VStack(spacing: 14) {
                                WarmapSectionTitle(
                                    title: "全部时刻",
                                    detail: "\(filteredEncounters.count) 条"
                                )

                                LazyVStack(spacing: 12) {
                                    ForEach(filteredEncounters) { encounter in
                                        NavigationLink {
                                            EncounterEditorView(encounter: encounter)
                                        } label: {
                                            EncounterRow(encounter: encounter)
                                        }
                                        .buttonStyle(WarmapPressButtonStyle())
                                    }
                                }
                            }
                            .transition(
                                WarmapMotion.transition(reduceMotion: reduceMotion)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 120)
                    .animation(
                        WarmapMotion.animation(reduceMotion: reduceMotion),
                        value: filteredEncounters.map(\.id)
                    )
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingNewEntry) {
                NavigationStack { EncounterEditorView() }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(
                    selectedPersonID: $selectedPersonID,
                    minimumRating: $minimumRating,
                    useDateRange: $useDateRange,
                    startDate: $startDate,
                    endDate: $endDate
                )
            }
        }
    }
}

private struct TimelineHeroCard: View {
    let count: Int
    let peopleCount: Int
    let averageRating: Double

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(WarmapTheme.surfaceRaised)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(WarmapTheme.coral)
                .frame(width: 5)
                .padding(.vertical, 18)

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("你的私人档案")
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                        Text("没有云端副本，也没有公开身份。")
                            .font(.caption)
                            .foregroundStyle(WarmapTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(WarmapTheme.mint)
                }

                HStack {
                    WarmapMetric(value: "\(count)", label: "记录")
                    Spacer()
                    WarmapMetric(value: "\(peopleCount)", label: "人物")
                    Spacer()
                    WarmapMetric(
                        value: count == 0
                            ? "—"
                            : averageRating.formatted(.number.precision(.fractionLength(1))),
                        label: "平均体验",
                        tint: WarmapTheme.gold
                    )
                }
            }
            .foregroundStyle(.white)
            .padding(22)
            .padding(.leading, 5)
        }
        .frame(minHeight: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WarmapTheme.hairline, lineWidth: 1)
        }
    }
}

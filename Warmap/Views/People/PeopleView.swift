import SwiftData
import SwiftUI

struct PeopleView: View {
    @Query(sort: \Person.nickname) private var people: [Person]
    @State private var showingNewPerson = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var totalEncounters: Int {
        people.reduce(0) { $0 + $1.encounters.count }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmapBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        WarmapPageHeader(
                            eyebrow: "Anonymous identities",
                            title: "人物档案",
                            subtitle: "只使用你能认出的代号，不需要真实姓名。"
                        ) {
                            WarmapIconButton(
                                systemName: "person.badge.plus",
                                accessibilityLabel: "新增人物",
                                prominent: true
                            ) {
                                showingNewPerson = true
                            }
                        }

                        PeopleOverviewCard(
                            peopleCount: people.count,
                            encounterCount: totalEncounters
                        )

                        if people.isEmpty {
                            WarmapCard {
                                WarmapEmptyState(
                                    systemName: "person.crop.circle.badge.plus",
                                    title: "建立第一张代号卡",
                                    message: "人物档案不需要照片、联系方式或真实姓名。",
                                    actionTitle: "新增人物"
                                ) {
                                    showingNewPerson = true
                                }
                            }
                        } else {
                            VStack(spacing: 14) {
                                WarmapSectionTitle(
                                    title: "全部人物",
                                    detail: "\(people.count) 位"
                                )

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(people) { person in
                                        NavigationLink {
                                            PersonDetailView(person: person)
                                        } label: {
                                            PersonRow(person: person)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingNewPerson) {
                NavigationStack { PersonEditorView() }
            }
        }
    }
}

private struct PeopleOverviewCard: View {
    let peopleCount: Int
    let encounterCount: Int

    var body: some View {
        WarmapCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(WarmapTheme.plum.opacity(0.22))
                        .frame(width: 66, height: 66)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(WarmapTheme.violet)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("匿名，是默认设置")
                        .font(.headline)
                        .foregroundStyle(WarmapTheme.textPrimary)
                    Text("不使用照片，不建立公开社交图谱。")
                        .font(.caption)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(peopleCount)")
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(WarmapTheme.coralSoft)
                    Text("\(encounterCount) 条记录")
                        .font(.caption)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }
            }
        }
    }
}

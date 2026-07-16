import SwiftData
import SwiftUI

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.nickname) private var people: [Person]

    @Binding var selectedPersonID: UUID?
    @Binding var minimumRating: Int
    @Binding var useDateRange: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date

    var body: some View {
        NavigationStack {
            ZStack {
                WarmapBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("筛选时间线")
                                    .font(.title2.bold())
                                    .foregroundStyle(WarmapTheme.textPrimary)
                                Text("组合条件，找到想回看的时刻。")
                                    .font(.subheadline)
                                    .foregroundStyle(WarmapTheme.textSecondary)
                            }
                            Spacer()
                            WarmapIconButton(
                                systemName: "xmark",
                                accessibilityLabel: "关闭"
                            ) {
                                dismiss()
                            }
                        }

                        WarmapFormSection("人物", systemName: "person.fill") {
                            Picker("人物", selection: $selectedPersonID) {
                                Text("全部人物").tag(nil as UUID?)
                                ForEach(people) { person in
                                    Text(person.nickname).tag(person.id as UUID?)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(WarmapTheme.coralSoft)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        WarmapFormSection(
                            "最低评分",
                            systemName: "star.fill",
                            detail: "\(minimumRating) 分"
                        ) {
                            RatingView(rating: $minimumRating)
                                .frame(maxWidth: .infinity)
                        }

                        WarmapFormSection("时间范围", systemName: "calendar") {
                            VStack(spacing: 14) {
                                Toggle("限制时间范围", isOn: $useDateRange)
                                    .tint(WarmapTheme.coral)

                                if useDateRange {
                                    WarmapDivider()
                                    DatePicker(
                                        "开始",
                                        selection: $startDate,
                                        displayedComponents: .date
                                    )
                                    DatePicker(
                                        "结束",
                                        selection: $endDate,
                                        in: startDate...,
                                        displayedComponents: .date
                                    )
                                }
                            }
                            .tint(WarmapTheme.coralSoft)
                            .foregroundStyle(WarmapTheme.textPrimary)
                        }

                        Button("应用筛选") {
                            dismiss()
                        }
                        .buttonStyle(WarmapPrimaryButtonStyle())

                        Button("重置全部") {
                            selectedPersonID = nil
                            minimumRating = 1
                            useDateRange = false
                        }
                        .buttonStyle(WarmapSecondaryButtonStyle())
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
    }
}

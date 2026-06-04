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
            Form {
                Picker("人物", selection: $selectedPersonID) {
                    Text("全部人物").tag(nil as UUID?)
                    ForEach(people) { person in
                        Text(person.nickname).tag(person.id as UUID?)
                    }
                }

                Stepper("最低评分：\(minimumRating)", value: $minimumRating, in: 1...5)

                Toggle("限制时间范围", isOn: $useDateRange)
                if useDateRange {
                    DatePicker("开始", selection: $startDate, displayedComponents: .date)
                    DatePicker("结束", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Button("重置筛选") {
                    selectedPersonID = nil
                    minimumRating = 1
                    useDateRange = false
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

import SwiftUI

struct PersonRow: View {
    let person: Person

    var body: some View {
        WarmapCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    WarmapAvatar(
                        name: person.nickname,
                        seed: person.id.uuidString,
                        size: 48
                    )

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color.white.opacity(0.24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(person.nickname)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(WarmapTheme.textPrimary)
                        .lineLimit(1)

                    Text("\(person.encounters.count) 条记录")
                        .font(.caption)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }

                HStack {
                    if let average = person.averageRating {
                        Label(
                            average.formatted(.number.precision(.fractionLength(1))),
                            systemImage: "star.fill"
                        )
                        .font(.caption.bold())
                        .foregroundStyle(WarmapTheme.gold)
                    } else {
                        Text("暂无评分")
                            .font(.caption)
                            .foregroundStyle(WarmapTheme.textSecondary)
                    }

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

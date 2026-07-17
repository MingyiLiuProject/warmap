import SwiftUI

struct EncounterRow: View {
    let encounter: Encounter

    var body: some View {
        WarmapCard(padding: 16) {
            HStack(alignment: .top, spacing: 15) {
                dateTile

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(encounter.person?.nickname ?? "未指定人物")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(WarmapTheme.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                            Text("\(encounter.rating).0")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(WarmapTheme.gold)
                    }

                    if !encounter.placeName.isEmpty {
                        Label(encounter.placeName, systemImage: "location.fill")
                            .font(.subheadline)
                            .foregroundStyle(WarmapTheme.textSecondary)
                            .lineLimit(1)
                    }

                    if !encounter.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(encounter.notes)
                            .font(.caption)
                            .foregroundStyle(WarmapTheme.textSecondary)
                            .lineLimit(2)
                    }

                    if !encounter.tags.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 7) {
                                ForEach(encounter.tags.prefix(3), id: \.self) { tag in
                                    WarmapTag(text: "#\(tag)")
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(WarmapTheme.textSecondary)
                    .padding(.top, 4)
            }
        }
    }

    private var dateTile: some View {
        VStack(spacing: 1) {
            Text(encounter.occurredAt, format: .dateTime.month(.abbreviated))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .foregroundStyle(WarmapTheme.coralSoft)

            Text(encounter.occurredAt, format: .dateTime.day())
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(WarmapTheme.textPrimary)
        }
        .frame(width: 54, height: 62)
        .background(WarmapTheme.coralSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(WarmapTheme.coral, lineWidth: 1)
        }
    }
}

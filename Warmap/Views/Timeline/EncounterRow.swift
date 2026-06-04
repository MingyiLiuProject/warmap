import SwiftUI

struct EncounterRow: View {
    let encounter: Encounter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(encounter.person?.nickname ?? "未指定人物")
                    .font(.headline)
                Spacer()
                Text(encounter.occurredAt, format: .dateTime.month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                RatingView(rating: .constant(encounter.rating), editable: false)
                Spacer()
                if !encounter.placeName.isEmpty {
                    Label(encounter.placeName, systemImage: "mappin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            if !encounter.tags.isEmpty {
                Text(encounter.tags.map { "#\($0)" }.joined(separator: "  "))
                    .font(.caption)
                    .foregroundStyle(.indigo)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}


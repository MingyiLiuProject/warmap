import SwiftUI

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 5) {
                Text(person.nickname)
                    .font(.headline)
                Text("\(person.encounters.count) 条记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let average = person.averageRating {
                Text(average, format: .number.precision(.fractionLength(1)))
                    .font(.title3.bold())
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}


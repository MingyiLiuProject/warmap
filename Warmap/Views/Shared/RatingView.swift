import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var editable = true

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...5, id: \.self) { value in
                Image(systemName: value <= rating ? "star.fill" : "star")
                    .foregroundStyle(value <= rating ? .orange : .secondary)
                    .onTapGesture {
                        if editable { rating = value }
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("评分 \(rating) 分")
    }
}


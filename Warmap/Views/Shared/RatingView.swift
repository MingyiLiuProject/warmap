import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var editable = true

    var body: some View {
        HStack(spacing: editable ? 10 : 5) {
            ForEach(1...5, id: \.self) { value in
                Image(systemName: value <= rating ? "star.fill" : "star")
                    .font(.system(size: editable ? 22 : 11, weight: .semibold))
                    .foregroundStyle(
                        value <= rating
                            ? WarmapTheme.gold
                            : Color.white.opacity(0.18)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editable {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                rating = value
                            }
                        }
                    }
                    .scaleEffect(editable && value == rating ? 1.18 : 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("评分 \(rating) 分")
    }
}

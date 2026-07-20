import SwiftUI

struct RatingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var rating: Int
    var editable = true

    var body: some View {
        HStack(spacing: editable ? 4 : 5) {
            ForEach(1...5, id: \.self) { value in
                if editable {
                    Button {
                        rating = value
                    } label: {
                        star(value: value, size: 22)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(WarmapPressButtonStyle(pressedScale: 0.9))
                    .accessibilityLabel("\(value) 分")
                    .accessibilityValue(value == rating ? "已选择" : "")
                } else {
                    star(value: value, size: 11)
                        .accessibilityHidden(true)
                }
            }
        }
        .animation(WarmapMotion.animation(reduceMotion: reduceMotion), value: rating)
        .sensoryFeedback(.selection, trigger: rating) { oldValue, newValue in
            editable && oldValue != newValue
        }
        .accessibilityElement(children: editable ? .contain : .ignore)
        .accessibilityLabel("体验评分")
        .accessibilityValue("5 分制，当前 \(rating) 分")
    }

    private func star(value: Int, size: CGFloat) -> some View {
        Image(systemName: value <= rating ? "star.fill" : "star")
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(
                value <= rating
                    ? WarmapTheme.gold
                    : WarmapTheme.hairline
            )
            .scaleEffect(
                editable && value == rating && !reduceMotion ? 1.12 : 1
            )
            .contentTransition(
                reduceMotion ? .opacity : .symbolEffect(.replace)
            )
    }
}

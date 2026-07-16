import SwiftUI

enum WarmapTheme {
    static let canvas = Color(red: 0.035, green: 0.032, blue: 0.055)
    static let canvasRaised = Color(red: 0.065, green: 0.057, blue: 0.09)
    static let coral = Color(red: 1.0, green: 0.39, blue: 0.42)
    static let coralSoft = Color(red: 1.0, green: 0.62, blue: 0.58)
    static let plum = Color(red: 0.48, green: 0.34, blue: 0.78)
    static let violet = Color(red: 0.68, green: 0.48, blue: 0.94)
    static let gold = Color(red: 0.96, green: 0.73, blue: 0.36)
    static let mint = Color(red: 0.39, green: 0.84, blue: 0.72)
    static let textPrimary = Color.white.opacity(0.96)
    static let textSecondary = Color.white.opacity(0.58)
    static let hairline = Color.white.opacity(0.09)

    static let accentGradient = LinearGradient(
        colors: [coralSoft, coral, plum],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let quietGradient = LinearGradient(
        colors: [Color.white.opacity(0.09), Color.white.opacity(0.035)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct WarmapBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                WarmapTheme.canvas

                Circle()
                    .fill(WarmapTheme.plum.opacity(0.25))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 90)
                    .offset(
                        x: proxy.size.width * 0.38,
                        y: -proxy.size.height * 0.36
                    )

                Circle()
                    .fill(WarmapTheme.coral.opacity(0.13))
                    .frame(width: proxy.size.width * 0.75)
                    .blur(radius: 100)
                    .offset(
                        x: -proxy.size.width * 0.42,
                        y: proxy.size.height * 0.36
                    )
            }
            .ignoresSafeArea()
        }
    }
}

struct WarmapBrandMark: View {
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.31, style: .continuous)
                .fill(WarmapTheme.accentGradient)

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: WarmapTheme.coral.opacity(0.3), radius: 18, y: 8)
        .accessibilityHidden(true)
    }
}

struct WarmapPageHeader<Trailing: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(
        eyebrow: String,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(WarmapTheme.coralSoft)

                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(WarmapTheme.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }
            }

            Spacer(minLength: 8)
            trailing
        }
    }
}

struct WarmapIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var prominent = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(prominent ? Color.white : WarmapTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background {
                    if prominent {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(WarmapTheme.accentGradient)
                    } else {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                            .overlay {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(WarmapTheme.hairline, lineWidth: 1)
                            }
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct WarmapCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(
        padding: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(WarmapTheme.quietGradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(WarmapTheme.hairline, lineWidth: 1)
                    }
            }
    }
}

struct WarmapFormSection<Content: View>: View {
    let title: String
    let systemName: String
    let detail: String?
    let content: Content

    init(
        _ title: String,
        systemName: String,
        detail: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.systemName = systemName
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: systemName)
                    .font(.caption.bold())
                    .foregroundStyle(WarmapTheme.coralSoft)
                    .frame(width: 27, height: 27)
                    .background(WarmapTheme.coral.opacity(0.1), in: Circle())

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WarmapTheme.textPrimary)

                Spacer()

                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(WarmapTheme.textSecondary)
                }
            }

            WarmapCard {
                content
            }
        }
    }
}

struct WarmapDivider: View {
    var body: some View {
        Rectangle()
            .fill(WarmapTheme.hairline)
            .frame(height: 1)
    }
}

struct WarmapSectionTitle: View {
    let title: String
    var detail: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
                .foregroundStyle(WarmapTheme.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(WarmapTheme.textSecondary)
            }
        }
    }
}

struct WarmapPrivacyPill: View {
    var text = "仅存本机"

    var body: some View {
        Label(text, systemImage: "lock.fill")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(WarmapTheme.mint)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(WarmapTheme.mint.opacity(0.1), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(WarmapTheme.mint.opacity(0.18), lineWidth: 1)
            }
    }
}

struct WarmapTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(WarmapTheme.coralSoft)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(WarmapTheme.coral.opacity(0.1), in: Capsule())
    }
}

struct WarmapSearchField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(WarmapTheme.textSecondary)

            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .foregroundStyle(WarmapTheme.textPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(WarmapTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 17))
        .overlay {
            RoundedRectangle(cornerRadius: 17)
                .stroke(WarmapTheme.hairline, lineWidth: 1)
        }
    }
}

struct WarmapEmptyState: View {
    let systemName: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        systemName: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(WarmapTheme.accentGradient)
                    .opacity(0.18)
                    .frame(width: 82, height: 82)

                Image(systemName: systemName)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(WarmapTheme.coralSoft)
            }

            VStack(spacing: 7) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(WarmapTheme.textPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(WarmapTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(WarmapPrimaryButtonStyle())
                    .frame(maxWidth: 220)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .padding(.horizontal, 24)
    }
}

struct WarmapAvatar: View {
    let name: String
    let seed: String
    var size: CGFloat = 54

    private var colors: [Color] {
        let palettes: [[Color]] = [
            [WarmapTheme.coralSoft, WarmapTheme.plum],
            [WarmapTheme.violet, Color(red: 0.27, green: 0.49, blue: 0.96)],
            [WarmapTheme.gold, WarmapTheme.coral],
            [WarmapTheme.mint, Color(red: 0.22, green: 0.55, blue: 0.62)]
        ]
        let value = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palettes[value % palettes.count]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
                .padding(3)

            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: colors[0].opacity(0.24), radius: 14, y: 7)
        .accessibilityHidden(true)
    }
}

struct WarmapMetric: View {
    let value: String
    let label: String
    var tint = WarmapTheme.textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
            Text(label)
                .font(.caption)
                .foregroundStyle(WarmapTheme.textSecondary)
        }
    }
}

struct WarmapPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(WarmapTheme.accentGradient, in: RoundedRectangle(cornerRadius: 17))
            .shadow(
                color: WarmapTheme.coral.opacity(configuration.isPressed ? 0.12 : 0.28),
                radius: configuration.isPressed ? 6 : 16,
                y: configuration.isPressed ? 3 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

struct WarmapSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(WarmapTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white.opacity(configuration.isPressed ? 0.11 : 0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(WarmapTheme.hairline, lineWidth: 1)
            }
    }
}

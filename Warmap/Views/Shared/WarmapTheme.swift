import SwiftUI

enum WarmapTheme {
    static let canvas = Color(red: 0.055, green: 0.067, blue: 0.09)
    static let canvasRaised = Color(red: 0.082, green: 0.098, blue: 0.13)
    static let surface = Color(red: 0.094, green: 0.114, blue: 0.15)
    static let surfaceRaised = Color(red: 0.12, green: 0.145, blue: 0.19)
    static let coral = Color(red: 0.96, green: 0.34, blue: 0.36)
    static let coralSoft = Color(red: 1.0, green: 0.46, blue: 0.46)
    static let coralSurface = Color(red: 0.24, green: 0.10, blue: 0.12)
    static let plum = Color(red: 0.37, green: 0.42, blue: 0.86)
    static let violet = Color(red: 0.48, green: 0.54, blue: 0.96)
    static let violetSurface = Color(red: 0.13, green: 0.15, blue: 0.29)
    static let gold = Color(red: 0.91, green: 0.66, blue: 0.24)
    static let mint = Color(red: 0.31, green: 0.76, blue: 0.62)
    static let mintSurface = Color(red: 0.08, green: 0.22, blue: 0.18)
    static let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let textSecondary = Color(red: 0.62, green: 0.66, blue: 0.73)
    static let hairline = Color(red: 0.17, green: 0.20, blue: 0.26)
}

struct WarmapBackground: View {
    var body: some View {
        WarmapTheme.canvas
            .ignoresSafeArea()
    }
}

struct WarmapBrandMark: View {
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.31, style: .continuous)
                .fill(WarmapTheme.coral)

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
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
                            .fill(WarmapTheme.coral)
                    } else {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(WarmapTheme.surfaceRaised)
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
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(WarmapTheme.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
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
                    .background(WarmapTheme.coralSurface, in: Circle())

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
            .background(WarmapTheme.mintSurface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(WarmapTheme.mint, lineWidth: 1)
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
            .background(WarmapTheme.coralSurface, in: Capsule())
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
        .background(WarmapTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
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
                    .fill(WarmapTheme.coralSurface)
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

    private var color: Color {
        let palette: [Color] = [
            WarmapTheme.coral,
            WarmapTheme.violet,
            WarmapTheme.gold,
            WarmapTheme.mint
        ]
        let value = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[value % palette.count]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color)

            Circle()
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
                .padding(3)

            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
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
            .background(
                configuration.isPressed ? WarmapTheme.coralSoft : WarmapTheme.coral,
                in: RoundedRectangle(cornerRadius: 14)
            )
    }
}

struct WarmapSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(WarmapTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                configuration.isPressed
                    ? WarmapTheme.surfaceRaised
                    : WarmapTheme.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(WarmapTheme.hairline, lineWidth: 1)
            }
    }
}

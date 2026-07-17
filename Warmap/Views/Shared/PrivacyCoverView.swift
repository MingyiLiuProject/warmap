import SwiftUI

struct PrivacyCoverView: View {
    var body: some View {
        ZStack {
            WarmapBackground()
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(WarmapTheme.surfaceRaised)
                        .frame(width: 92, height: 92)
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(WarmapTheme.coralSoft)
                }
                Text("内容已隐藏")
                    .font(.title2.bold())
                    .foregroundStyle(WarmapTheme.textPrimary)
                Text("停止屏幕录制或镜像后恢复显示")
                    .font(.subheadline)
                    .foregroundStyle(WarmapTheme.textSecondary)
            }
        }
    }
}

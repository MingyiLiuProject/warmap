import SwiftUI

struct PrivacyCoverView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(.indigo)
                Text("内容已隐藏")
                    .font(.headline)
                Text("停止屏幕录制或镜像后恢复显示")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

import LocalAuthentication
import SwiftUI

@MainActor
final class AppLockManager: ObservableObject {
    @Published private(set) var isLocked = true
    @Published private(set) var errorMessage: String?

    func lock() {
        isLocked = true
    }

    func unlock() async {
        guard isLocked else { return }

        let context = LAContext()
        context.localizedCancelTitle = "保持锁定"
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            errorMessage = "请先在系统设置中启用设备密码或生物识别。"
            return
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "解锁你的私密记录"
            )
            if success {
                isLocked = false
                errorMessage = nil
            }
        } catch {
            errorMessage = "验证未完成，请重试。"
        }
    }
}


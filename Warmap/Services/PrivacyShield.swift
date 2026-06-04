import Combine
import UIKit

@MainActor
final class PrivacyShield: ObservableObject {
    @Published private(set) var shouldObscure = UIScreen.main.isCaptured
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIScreen.capturedDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.shouldObscure = UIScreen.main.isCaptured
            }
    }
}

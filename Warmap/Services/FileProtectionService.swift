import Foundation

enum FileProtectionService {
    static func protectApplicationSupport() {
        guard let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }

        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: directory.path
        )
    }
}

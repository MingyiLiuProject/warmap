import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let warmapBackup = UTType(exportedAs: "com.mingyiliuproject.warmap.backup")
}

struct WarmapBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.warmapBackup, .data] }
    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}


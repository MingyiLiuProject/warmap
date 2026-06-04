import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var people: [Person]
    @Query private var encounters: [Encounter]

    @State private var passwordMode: PasswordPromptView.Mode?
    @State private var pendingImportData: Data?
    @State private var exportDocument: WarmapBackupDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("隐私") {
                    Label("无账号、无云同步", systemImage: "icloud.slash")
                    Label("离开应用自动锁定", systemImage: "lock.fill")
                    Label("录屏或镜像时隐藏内容", systemImage: "eye.slash.fill")
                }

                Section("加密备份") {
                    Button {
                        passwordMode = .export
                    } label: {
                        Label("导出加密备份", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Label("导入加密备份", systemImage: "square.and.arrow.down")
                    }

                    Text("备份使用 PBKDF2-SHA256 派生密钥，并通过 AES-GCM 加密和校验。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("本机数据") {
                    LabeledContent("人物", value: "\(people.count)")
                    LabeledContent("记录", value: "\(encounters.count)")
                }

                Section("说明") {
                    Text("Warmap 不包含账号、广告、分析或记录上传代码。地图页可能通过 Apple MapKit 获取地图瓦片。设备被解锁或系统被攻破时，任何应用都无法保证绝对保密。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .sheet(item: $passwordMode) { mode in
                PasswordPromptView(mode: mode) { password in
                    switch mode {
                    case .export:
                        prepareExport(password: password)
                    case .importBackup:
                        performImport(password: password)
                    }
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: exportDocument,
                contentType: .warmapBackup,
                defaultFilename: "warmap-backup"
            ) { result in
                if case .failure(let error) = result {
                    alertMessage = error.localizedDescription
                }
                exportDocument = nil
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.warmapBackup, .data]
            ) { result in
                do {
                    let url = try result.get()
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    pendingImportData = try Data(contentsOf: url)
                    passwordMode = .importBackup
                } catch {
                    alertMessage = error.localizedDescription
                }
            }
            .alert(
                "Warmap",
                isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )
            ) {
                Button("好", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func prepareExport(password: String) {
        do {
            let archive = ArchiveStoreService.makeArchive(
                people: people,
                encounters: encounters
            )
            exportDocument = WarmapBackupDocument(
                data: try ArchiveCryptoService.encrypt(archive, password: password)
            )
            showingExporter = true
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    private func performImport(password: String) {
        guard let pendingImportData else { return }
        do {
            let archive = try ArchiveCryptoService.decrypt(pendingImportData, password: password)
            try ArchiveStoreService.importArchive(archive, into: modelContext)
            self.pendingImportData = nil
            alertMessage = "导入完成，共恢复 \(archive.encounters.count) 条记录。"
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}

extension PasswordPromptView.Mode: Identifiable {
    var id: String {
        switch self {
        case .export: return "export"
        case .importBackup: return "import"
        }
    }
}

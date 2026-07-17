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
            ZStack {
                WarmapBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        WarmapPageHeader(
                            eyebrow: "Privacy control",
                            title: "安全中心",
                            subtitle: "看清数据在哪里，也掌握如何带走它。"
                        ) {
                            WarmapBrandMark(size: 44)
                        }

                        privacyScoreCard
                        protectionCard
                        backupSection
                        localDataCard
                        disclosureCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
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

    private var privacyScoreCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(WarmapTheme.surfaceRaised)

            HStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(
                            WarmapTheme.coral,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("4/4")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("已启用")
                            .font(.caption2)
                            .foregroundStyle(WarmapTheme.textSecondary)
                    }
                }
                .frame(width: 92, height: 92)

                VStack(alignment: .leading, spacing: 7) {
                    Label("本机保护完整", systemImage: "checkmark.shield.fill")
                        .font(.headline)
                        .foregroundStyle(WarmapTheme.mint)
                    Text("账号、云同步、广告追踪与记录上传均未启用。")
                        .font(.subheadline)
                        .foregroundStyle(WarmapTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(22)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }

    private var protectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            WarmapSectionTitle(title: "保护状态")

            WarmapCard {
                VStack(spacing: 15) {
                    protectionRow(
                        icon: "person.crop.circle.badge.xmark",
                        title: "无账号",
                        message: "无需邮箱、手机号或身份资料"
                    )
                    WarmapDivider()
                    protectionRow(
                        icon: "icloud.slash.fill",
                        title: "无云同步",
                        message: "日常数据只存在这台设备"
                    )
                    WarmapDivider()
                    protectionRow(
                        icon: "lock.fill",
                        title: "自动锁定",
                        message: "离开应用后重新验证"
                    )
                    WarmapDivider()
                    protectionRow(
                        icon: "eye.slash.fill",
                        title: "录屏遮挡",
                        message: "检测到录屏或镜像时隐藏内容"
                    )
                }
            }
        }
    }

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WarmapSectionTitle(
                title: "加密迁移",
                detail: "AES-GCM"
            )

            HStack(spacing: 12) {
                BackupActionCard(
                    title: "导出",
                    subtitle: "创建密码备份",
                    systemName: "arrow.up.doc.fill",
                    tint: WarmapTheme.coralSoft,
                    iconBackground: WarmapTheme.coralSurface
                ) {
                    passwordMode = .export
                }

                BackupActionCard(
                    title: "导入",
                    subtitle: "恢复本机数据",
                    systemName: "arrow.down.doc.fill",
                    tint: WarmapTheme.violet,
                    iconBackground: WarmapTheme.violetSurface
                ) {
                    showingImporter = true
                }
            }

            Text("密码只在本机用于派生加密密钥。Warmap 无法找回遗失的备份密码。")
                .font(.caption)
                .foregroundStyle(WarmapTheme.textSecondary)
                .padding(.horizontal, 2)
        }
    }

    private var localDataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            WarmapSectionTitle(title: "本机档案")

            WarmapCard {
                HStack {
                    WarmapMetric(value: "\(encounters.count)", label: "记录")
                    Spacer()
                    WarmapMetric(value: "\(people.count)", label: "人物")
                    Spacer()
                    WarmapMetric(
                        value: encounters.filter {
                            $0.latitude != nil && $0.longitude != nil
                        }.count.formatted(),
                        label: "地图节点",
                        tint: WarmapTheme.mint
                    )
                }
            }
        }
    }

    private var disclosureCard: some View {
        WarmapCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("透明说明", systemImage: "info.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(WarmapTheme.textPrimary)

                Text("Warmap 不包含账号、广告、分析或记录上传代码。地图页可能通过 Apple MapKit 获取地图瓦片。设备被解锁或系统被攻破时，任何应用都无法保证绝对保密。")
                    .font(.caption)
                    .foregroundStyle(WarmapTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func protectionRow(
        icon: String,
        title: String,
        message: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WarmapTheme.mint)
                .frame(width: 36, height: 36)
                .background(WarmapTheme.mintSurface, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(WarmapTheme.textPrimary)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(WarmapTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(WarmapTheme.mint)
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

private struct BackupActionCard: View {
    let title: String
    let subtitle: String
    let systemName: String
    let tint: Color
    let iconBackground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            WarmapCard(padding: 16) {
                VStack(alignment: .leading, spacing: 15) {
                    Image(systemName: systemName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 42, height: 42)
                        .background(iconBackground, in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(WarmapTheme.textPrimary)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(WarmapTheme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
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

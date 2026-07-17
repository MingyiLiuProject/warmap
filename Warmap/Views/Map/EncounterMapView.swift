import MapKit
import SwiftData
import SwiftUI

private struct MapEncounter: Identifiable {
    let encounter: Encounter
    let coordinate: CLLocationCoordinate2D
    var id: UUID { encounter.id }
}

struct EncounterMapView: View {
    @Query(sort: \Encounter.occurredAt, order: .reverse) private var encounters: [Encounter]
    @State private var selectedEncounter: Encounter?
    @State private var position: MapCameraPosition = .automatic

    private var mapEncounters: [MapEncounter] {
        encounters.compactMap { encounter in
            guard let latitude = encounter.latitude, let longitude = encounter.longitude else {
                return nil
            }
            return MapEncounter(
                encounter: encounter,
                coordinate: LocationPrivacy.blurredCoordinate(
                    latitude: latitude,
                    longitude: longitude
                )
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if mapEncounters.isEmpty {
                    WarmapBackground()

                    ScrollView {
                        VStack(spacing: 28) {
                            WarmapPageHeader(
                                eyebrow: "Blurred geography",
                                title: "记忆地图",
                                subtitle: "地点帮助回忆，但不需要暴露精确坐标。"
                            ) {
                                WarmapPrivacyPill(text: "位置已模糊")
                            }

                            WarmapCard {
                                WarmapEmptyState(
                                    systemName: "map.fill",
                                    title: "地图还没有节点",
                                    message: "为记录加入可选坐标后，这里会显示约公里级的匿名位置。"
                                )
                            }

                            privacyExplanation
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 120)
                    }
                } else {
                    mapContent
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedEncounter) { encounter in
                NavigationStack {
                    EncounterEditorView(encounter: encounter)
                }
                .presentationDetents([.large])
            }
        }
    }

    private var mapContent: some View {
        ZStack {
            Map(position: $position) {
                ForEach(mapEncounters) { item in
                    Annotation(
                        item.encounter.person?.nickname ?? "记录",
                        coordinate: item.coordinate
                    ) {
                        Button {
                            selectedEncounter = item.encounter
                        } label: {
                            WarmapMapNode(rating: item.encounter.rating)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                WarmapCard(padding: 14) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PRIVATE GEOGRAPHY")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1.6)
                                .foregroundStyle(WarmapTheme.coralSoft)
                            Text("记忆地图")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(WarmapTheme.textPrimary)
                        }

                        Spacer()
                        WarmapPrivacyPill(text: "约公里级")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                WarmapCard(padding: 15) {
                    HStack(spacing: 13) {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(WarmapTheme.mint)
                            .frame(width: 40, height: 40)
                            .background(WarmapTheme.mintSurface, in: Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(mapEncounters.count) 个模糊位置")
                                .font(.subheadline.bold())
                                .foregroundStyle(WarmapTheme.textPrimary)
                            Text("点击位置节点查看记录，精确坐标不会显示在地图上。")
                                .font(.caption)
                                .foregroundStyle(WarmapTheme.textSecondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    private var privacyExplanation: some View {
        WarmapCard {
            VStack(alignment: .leading, spacing: 16) {
                WarmapSectionTitle(title: "地图如何保护你")

                mapPrivacyRow(
                    icon: "scope",
                    title: "自动降低精度",
                    message: "经纬度在展示前会被取整，不显示精确门牌位置。"
                )
                WarmapDivider()
                mapPrivacyRow(
                    icon: "person.crop.circle.badge.xmark",
                    title: "不显示公开身份",
                    message: "地图节点只关联你的本地代号。"
                )
            }
        }
    }

    private func mapPrivacyRow(
        icon: String,
        title: String,
        message: String
    ) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(WarmapTheme.coralSoft)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(WarmapTheme.textPrimary)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(WarmapTheme.textSecondary)
            }
        }
    }
}

private struct WarmapMapNode: View {
    let rating: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(WarmapTheme.coralSurface)
                .frame(width: 48, height: 48)

            Circle()
                .fill(WarmapTheme.coral)
                .frame(width: 25, height: 25)
                .overlay {
                    Circle().stroke(Color.white.opacity(0.68), lineWidth: 2)
                }

            Text("\(rating)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("评分 \(rating) 分的记录")
    }
}

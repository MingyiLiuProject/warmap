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
            Group {
                if mapEncounters.isEmpty {
                    ContentUnavailableView(
                        "没有地图记录",
                        systemImage: "map",
                        description: Text("为记录添加可选坐标后，会以模糊位置显示在地图上。")
                    )
                } else {
                    Map(position: $position) {
                        ForEach(mapEncounters) { item in
                            Annotation(
                                item.encounter.person?.nickname ?? "记录",
                                coordinate: item.coordinate
                            ) {
                                Button {
                                    selectedEncounter = item.encounter
                                } label: {
                                    Image(systemName: "circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.indigo)
                                        .background(.white, in: Circle())
                                }
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .flat))
                    .safeAreaInset(edge: .bottom) {
                        Text("地图位置已模糊化，约保留公里级精度")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                            .padding()
                    }
                }
            }
            .navigationTitle("地图")
            .sheet(item: $selectedEncounter) { encounter in
                NavigationStack {
                    EncounterEditorView(encounter: encounter)
                }
                .presentationDetents([.large])
            }
        }
    }
}


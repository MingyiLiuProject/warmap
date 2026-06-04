import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem { Label("记录", systemImage: "clock") }

            PeopleView()
                .tabItem { Label("人物", systemImage: "person.2") }

            EncounterMapView()
                .tabItem { Label("地图", systemImage: "map") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(.indigo)
    }
}


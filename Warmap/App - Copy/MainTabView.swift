import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem { Label("时间线", systemImage: "sparkles") }

            PeopleView()
                .tabItem { Label("人物", systemImage: "person.2.fill") }

            EncounterMapView()
                .tabItem { Label("地图", systemImage: "map.fill") }

            SettingsView()
                .tabItem { Label("安全", systemImage: "lock.shield.fill") }
        }
        .tint(WarmapTheme.coralSoft)
        .toolbarBackground(WarmapTheme.canvasRaised, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

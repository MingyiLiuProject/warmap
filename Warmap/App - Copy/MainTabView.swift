import SwiftUI

struct MainTabView: View {
    private enum Tab: Hashable {
        case timeline
        case people
        case map
        case security
    }

    @State private var selection: Tab = .timeline

    var body: some View {
        TabView(selection: $selection) {
            TimelineView()
                .tabItem { Label("时间线", systemImage: "sparkles") }
                .tag(Tab.timeline)

            PeopleView()
                .tabItem { Label("人物", systemImage: "person.2.fill") }
                .tag(Tab.people)

            EncounterMapView()
                .tabItem { Label("地图", systemImage: "map.fill") }
                .tag(Tab.map)

            SettingsView()
                .tabItem { Label("安全", systemImage: "lock.shield.fill") }
                .tag(Tab.security)
        }
        .tint(WarmapTheme.coralSoft)
        .toolbarBackground(WarmapTheme.canvasRaised, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

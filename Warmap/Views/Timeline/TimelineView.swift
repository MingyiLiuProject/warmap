import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Encounter.occurredAt, order: .reverse) private var encounters: [Encounter]

    @State private var searchText = ""
    @State private var selectedPersonID: UUID?
    @State private var minimumRating = 1
    @State private var useDateRange = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate = Date.now
    @State private var showingFilters = false
    @State private var showingNewEntry = false

    private var filteredEncounters: [Encounter] {
        encounters.filter { encounter in
            let searchMatches = searchText.isEmpty
                || encounter.placeName.localizedCaseInsensitiveContains(searchText)
                || encounter.person?.nickname.localizedCaseInsensitiveContains(searchText) == true
                || encounter.tagsText.localizedCaseInsensitiveContains(searchText)
            let personMatches = selectedPersonID == nil || encounter.person?.id == selectedPersonID
            let dateMatches = !useDateRange
                || (encounter.occurredAt >= startDate && encounter.occurredAt <= endDate)
            return searchMatches && personMatches && dateMatches && encounter.rating >= minimumRating
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if encounters.isEmpty {
                    ContentUnavailableView(
                        "还没有记录",
                        systemImage: "lock.doc",
                        description: Text("创建第一条仅保存在本机的记录。")
                    )
                } else if filteredEncounters.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredEncounters) { encounter in
                            NavigationLink {
                                EncounterEditorView(encounter: encounter)
                            } label: {
                                EncounterRow(encounter: encounter)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("记录")
            .searchable(text: $searchText, prompt: "人物、地点或标签")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingFilters = true
                    } label: {
                        Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewEntry = true
                    } label: {
                        Label("新增", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NavigationStack { EncounterEditorView() }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(
                    selectedPersonID: $selectedPersonID,
                    minimumRating: $minimumRating,
                    useDateRange: $useDateRange,
                    startDate: $startDate,
                    endDate: $endDate
                )
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEncounters[index])
        }
    }
}

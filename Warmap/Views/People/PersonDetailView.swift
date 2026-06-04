import SwiftUI

struct PersonDetailView: View {
    let person: Person
    @State private var showingEdit = false

    private var sortedEncounters: [Encounter] {
        person.encounters.sorted { $0.occurredAt > $1.occurredAt }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Label("\(person.encounters.count) 次", systemImage: "number")
                    Spacer()
                    if let average = person.averageRating {
                        Label(
                            average.formatted(.number.precision(.fractionLength(1))),
                            systemImage: "star.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                }
            }

            if !person.tags.isEmpty {
                Section("标签") {
                    Text(person.tags.map { "#\($0)" }.joined(separator: "  "))
                        .foregroundStyle(.indigo)
                }
            }

            Section("记录") {
                if sortedEncounters.isEmpty {
                    Text("暂无关联记录")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedEncounters) { encounter in
                        NavigationLink {
                            EncounterEditorView(encounter: encounter)
                        } label: {
                            EncounterRow(encounter: encounter)
                        }
                    }
                }
            }
        }
        .navigationTitle(person.nickname)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack { PersonEditorView(person: person) }
        }
    }
}


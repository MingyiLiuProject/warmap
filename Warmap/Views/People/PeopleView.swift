import SwiftData
import SwiftUI

struct PeopleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.nickname) private var people: [Person]
    @State private var showingNewPerson = false

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView(
                        "还没有人物",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("使用昵称或代号，避免记录真实姓名。")
                    )
                } else {
                    List {
                        ForEach(people) { person in
                            NavigationLink {
                                PersonDetailView(person: person)
                            } label: {
                                PersonRow(person: person)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("人物")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewPerson = true
                    } label: {
                        Label("新增人物", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPerson) {
                NavigationStack { PersonEditorView() }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(people[index])
        }
    }
}


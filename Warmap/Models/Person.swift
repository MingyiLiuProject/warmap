import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID
    var nickname: String
    var tagsText: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Encounter.person)
    var encounters: [Encounter]

    init(nickname: String, tagsText: String = "") {
        self.id = UUID()
        self.nickname = nickname
        self.tagsText = tagsText
        self.createdAt = .now
        self.encounters = []
    }

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var averageRating: Double? {
        guard !encounters.isEmpty else { return nil }
        return Double(encounters.map(\.rating).reduce(0, +)) / Double(encounters.count)
    }
}


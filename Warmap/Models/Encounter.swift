import Foundation
import SwiftData

@Model
final class Encounter {
    var id: UUID
    var occurredAt: Date
    var placeName: String
    var latitude: Double?
    var longitude: Double?
    var rating: Int
    var tagsText: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var person: Person?

    init(
        occurredAt: Date = .now,
        placeName: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Int = 5,
        tagsText: String = "",
        notes: String = "",
        person: Person? = nil
    ) {
        self.id = UUID()
        self.occurredAt = occurredAt
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.tagsText = tagsText
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
        self.person = person
    }

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

import Foundation

struct WarmapArchive: Codable {
    var version: Int = 1
    var exportedAt: Date = .now
    var people: [PersonArchive]
    var encounters: [EncounterArchive]
}

struct PersonArchive: Codable {
    var id: UUID
    var nickname: String
    var tagsText: String
    var createdAt: Date
}

struct EncounterArchive: Codable {
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
    var personID: UUID?
}

struct EncryptedArchiveEnvelope: Codable {
    var format: String = "warmap-aes-gcm"
    var version: Int = 1
    var iterations: Int
    var salt: Data
    var nonce: Data
    var ciphertext: Data
    var tag: Data
}


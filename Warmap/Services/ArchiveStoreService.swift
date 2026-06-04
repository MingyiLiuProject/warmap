import Foundation
import SwiftData

enum ArchiveStoreService {
    static func makeArchive(people: [Person], encounters: [Encounter]) -> WarmapArchive {
        WarmapArchive(
            people: people.map {
                PersonArchive(
                    id: $0.id,
                    nickname: $0.nickname,
                    tagsText: $0.tagsText,
                    createdAt: $0.createdAt
                )
            },
            encounters: encounters.map {
                EncounterArchive(
                    id: $0.id,
                    occurredAt: $0.occurredAt,
                    placeName: $0.placeName,
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    rating: $0.rating,
                    tagsText: $0.tagsText,
                    notes: $0.notes,
                    createdAt: $0.createdAt,
                    updatedAt: $0.updatedAt,
                    personID: $0.person?.id
                )
            }
        )
    }

    @MainActor
    static func importArchive(_ archive: WarmapArchive, into context: ModelContext) throws {
        let existingPeople = try context.fetch(FetchDescriptor<Person>())
        let existingEncounters = try context.fetch(FetchDescriptor<Encounter>())
        var peopleByID = Dictionary(uniqueKeysWithValues: existingPeople.map { ($0.id, $0) })
        let encountersByID = Dictionary(uniqueKeysWithValues: existingEncounters.map { ($0.id, $0) })

        for item in archive.people {
            if let person = peopleByID[item.id] {
                person.nickname = item.nickname
                person.tagsText = item.tagsText
            } else {
                let person = Person(nickname: item.nickname, tagsText: item.tagsText)
                person.id = item.id
                person.createdAt = item.createdAt
                context.insert(person)
                peopleByID[item.id] = person
            }
        }

        for item in archive.encounters {
            let person = item.personID.flatMap { peopleByID[$0] }
            if let encounter = encountersByID[item.id] {
                encounter.occurredAt = item.occurredAt
                encounter.placeName = item.placeName
                encounter.latitude = item.latitude
                encounter.longitude = item.longitude
                encounter.rating = item.rating
                encounter.tagsText = item.tagsText
                encounter.notes = item.notes
                encounter.updatedAt = item.updatedAt
                encounter.person = person
            } else {
                let encounter = Encounter(
                    occurredAt: item.occurredAt,
                    placeName: item.placeName,
                    latitude: item.latitude,
                    longitude: item.longitude,
                    rating: item.rating,
                    tagsText: item.tagsText,
                    notes: item.notes,
                    person: person
                )
                encounter.id = item.id
                encounter.createdAt = item.createdAt
                encounter.updatedAt = item.updatedAt
                context.insert(encounter)
            }
        }

        try context.save()
    }
}

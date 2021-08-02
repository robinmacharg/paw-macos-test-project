//
//  Model.swift
//  Superheroes
//
//  Created by Robin Macharg2 on 28/07/2021.
//
// The application datamodel.  A Singleton.  Could be CoreData, time permitting.

import Foundation

public final class Model {

    // Singleton
    public static let shared = Model()

    /// The history of HTTP requests
    private var history: [Any] = []

    /// A list of superhero squads
    var squads: [SuperheroSquad] = []

    /// Constants used to populate our model with random squads of randomm superheroes.
    /// Any resemblance to actual superheroes or squads is purely accidental.
    private struct constants {
        static let ageRange = 0...2000
        static let formedRange = -5000...2022
        static let squadNames = ["The Hot Bonnets", "The Alcaseltzers", "The Goliaths", "The Forensic Twins"]
        static let homeTowns = ["Glasgow", "Bristol", "Stockholm", "Artemis", "Diemos", "Tel Aviv"]
        static let names = ["Johnny Sixpack", "Bob", "Dave", "Stupendous Liar", "Tightfit", "King Crazy", "Mwah Ha", "Philip", "The Strangler"]
        static let secretIdentity = ["Carol Drew", "Mild Mannered Janitor", "Taxi Driver", "Dennis Arkwright", "Column Inches"]
        static let powers = ["Invisibility", "Strength", "X-Ray Vision", "Overwhelming Body Odour", "A Good Sense of Humor", "Mimicry", "Repetition", "Repetition", "Irony"]

        /// The maximum number of powers a superhero may have
        static let maxPowers = powers.count
    }

    // Private to support the singleton pattern
    private init() {}

    /**
     * Populate the model with random data.
     *
     * Note: maxMembers can exceed the number of heros at our disposal and lead to a hero being included multiple times.  This could be
     * due to e.g. quantum effects, time travel or multiple realities.  Ours is not to reason why, etc.  In a similar vein duplicates
     * (e.g. secret identity) are not checked for.  We can invent some good reasons for this, but the specification did not explicitly
     * state this as a requirement.  And, you know, quantum.
     *
     * - Parameters:
     *   - squads: The number of squads to generate
     *   - maxMembers: An optional maximum number of squad members
     */
    func populateWithRandomData(squads: Int, maxMembers: Int? = nil) {

        self.squads = []

        // The alternate syntax of "(1...squads).forEach({ _ in ..." avoids the discarding _ assignment (likely compiled away anyway?) but
        // is less idiomatic, IMHO.
        for _ in 1...squads {
            var squadMembers: [Member] = []

            for _ in 1...Int.random(in: 1...(maxMembers ?? constants.names.count)) {
                if let name = constants.names.randomElement(),
                   let secretIdentity = constants.secretIdentity.randomElement()
                {
                    // Start with all powers, remove powers until we have the correct number.
                    // This avoids potential duplicates. The alternative is to not care and dedupe at the end.
                    var heroPowers = constants.powers // Value type, shallow copy suffices
                    let powerCount = Int.random(in: 1...constants.maxPowers)
                    while heroPowers.count > powerCount {
                        heroPowers.remove(at: Int.random(in: 1...heroPowers.count) - 1)
                    }

                    squadMembers.append(
                        Member(
                            name: name,
                            age: Int.random(in: constants.ageRange),
                            secretIdentity: secretIdentity,
                            powers: heroPowers))
                }
            }

            if let squadName = constants.squadNames.randomElement(),
               let homeTown = constants.homeTowns.randomElement()
            {
                let squad = SuperheroSquad(
                    size: Int.random(in: 0...constants.names.count),
                    squadName: squadName,
                    homeTown: homeTown,
                    formed: Int.random(in: constants.formedRange),
                    active: Bool.random(),
                    members: squadMembers)

                self.squads.append(squad)
            }
        }
    }

    /**
     * Convert the model to JSON, pretty-printing if desired
     *
     * - Parameters:
     *   - prettyPrint: An optional boolean indicating whether to pretty-print the generated JSON
     */
    func asJSON(prettyPrint: Bool = false) -> Result<String, SuperHeroError> {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }

        do {
            let jsonData = try encoder.encode(squads)
            if let jsonString = String(data: jsonData, encoding: .utf8)
            {
                return .success(jsonString)
            }
        }
        catch let e {
            fatalError("Failed to encode Superhero Squads: \(e.localizedDescription)")
        }

        return .failure(SuperHeroError.failedToEncode)
    }
}

//
//  SuperheroSquad.swift
//  Superheroes
//
//  Created by Robin Macharg on 27/07/2021.
//

import Foundation

//   let superheroSquad = try? newJSONDecoder().decode(SuperheroSquad.self, from: jsonData)

// MARK: - SuperheroSquad
struct SuperheroSquad: Codable, Equatable {
    let squadName: String
    let homeTown: String
    let formed: Int
    let active: Bool
    let members: [Member]

    init(
        size: Int = 0,
        squadName: String = squadNames.randomElement() ?? "The Unknown Soldiers",
        homeTown: String = homeTowns.randomElement() ?? "Voidville",
        formed: Int = Int.random(in: 0...2022),
        active: Bool = Bool.random(),
        members: [Member] = [])
    {
        self.squadName = squadName
        self.homeTown = homeTown
        self.formed = formed
        self.active = active
        self.members = members
    }
}

// MARK: - Member
struct Member: Codable, Equatable {
    let name: String
    let age: Int
    let secretIdentity: String
    let powers: [String]
}

let squadNames = ["", ""]
let homeTowns = ["", ""]

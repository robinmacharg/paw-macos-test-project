//
//  MainVCViewModel.swift
//  Superheroes
//
//  Created by Robin Macharg on 04/08/2021.
//

import Foundation

enum RequestState {
    case created
    case inProgress
    case finished
}

struct Request {
    var id: UUID
    var squads: [SuperheroSquad]
    var request: URLRequest
    var state: RequestState
}

struct MainVCViewModel {
    var history: [Request] = []
    var currentRequest: Request? = nil
}

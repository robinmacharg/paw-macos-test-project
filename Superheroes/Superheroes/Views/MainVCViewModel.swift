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

@objc class Request: NSObject {
    @objc var id: UUID
    var squads: [SuperheroSquad] = []
    var request: URLRequest
    var state: RequestState
    
    @objc var idAsString: String {
        return self.id.uuidString
    }
    
    init(id: UUID, squads: [SuperheroSquad] , request: URLRequest, state: RequestState) {
        self.id = UUID()
        self.squads = squads
        self.request = request
        self.state = state
//        let foo = URL
    }
}

@objc class MainVCViewModel: NSObject {
    @objc var history: [Request] = [Request(id: UUID(), squads: [], request: URLRequest(url: URL(string: "http://djfhjsdf")!), state: .created)]
    var currentRequest: Request? = nil
    
    
}

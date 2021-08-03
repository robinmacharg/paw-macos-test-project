//
//  API.swift
//  Superheroes
//
//  Created by Robin Macharg2 on 02/08/2021.
//
// Handles network communication with the backend

import Foundation

public final class API {

    // Singleton
    public static let shared = API()

    struct constants {
        static let endPoint = "https://httpbin.org/anything"
    }

    // Private to support the singleton pattern
    private init() {}

    func sendRequest(request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            // Check for fundamental networking error
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            // Check for HTTP errors
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            // PArse out data field
            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
               let json = response["data"] as? String,
               let data = json.data(using: .utf8)
            {
                let decoder = JSONDecoder()
                let superheroSquad = try? decoder.decode([SuperheroSquad].self, from: data)
                print(superheroSquad)
            }

            // Error
            else {

            }
        }

        task.resume()
    }
}

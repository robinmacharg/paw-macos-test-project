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
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }

        task.resume()
    }
}

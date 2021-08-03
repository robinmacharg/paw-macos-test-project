//
//  ViewController.swift
//  Superheroes
//
//  Created by Robin Macharg2 on 01/08/2021.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        Model.shared.populateWithRandomData(squads: 3)

        outlineView.reloadData()

        // The following is likely overkill for this exercise but is left in (along with the appropriate Model code) to show good
        // error-handling hygeine.
        let json = Model.shared.asJSON(prettyPrint: true)
        switch json {
        case .success(let jsonString):
            print(jsonString)
            sendRequest(bodyText: jsonString)
        case .failure(let error):
            switch error {
            case .failedToEncode:
                print("Failed to encode the model correctly")
            }
        }
    }

    override func viewWillAppear() {

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // Helpers

    private func sendRequest(bodyText: String) {
        // Send a request
        guard let url = URL(string: API.constants.endPoint) else {
            fatalError("Unable to generate endpoint URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyText.data(using: .utf8)
        request.setValue("\(String(describing: bodyText.data(using: .utf8)?.count))", forHTTPHeaderField: "Content-Length")

        API.shared.sendRequest(request: request)
    }
}

// MARK: - <NSOutlineViewDataSource>

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let squad = item as? SuperheroSquad {
            return squad.members.count
        }
        return Model.shared.squads.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let squad = item as? SuperheroSquad {
            return squad.members[index]
        }
        return Model.shared.squads[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let squad = item as? SuperheroSquad {
            return squad.members.count > 0
        }
        return false
    }
}

// MARK: - <NSOutlineViewDelegate>

extension ViewController: NSOutlineViewDelegate {

}



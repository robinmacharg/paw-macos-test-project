//
//  ViewController.swift
//  Superheroes
//
//  Created by Robin Macharg2 on 01/08/2021.
//

import Cocoa

class MainVC: NSViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var outlineView: NSOutlineView!

    // MARK: - Properties
    
    var model: MainVCViewModel = MainVCViewModel()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Actions
    
    /**
     * Build and submit a request, updating the model on success
     */
    @IBAction func submitRequest(_ sender: Any) {
        let squads = Data.createSquads(squads: 3, maxMembers: 5)
        let request = API.makeURLRequest(squads: squads)
        
        switch request {
        case .success(let urlRequest):
            let request = Request(id: UUID(), squads: squads, request: urlRequest, state: .created)
            
            model.history.append(request)
            
            API.sendRequest(request) { [self] request in
                print("callback", self, request)
            }
        case .failure(let error):
            fatalError("unhandled")
        }
    }
}

// MARK: - <NSOutlineViewDataSource>

extension MainVC: NSOutlineViewDataSource {
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        return model.currentRequest?.squads.count ?? 0
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        if let squad = item as? SuperheroSquad {
//            return squad.members[index]
//        }
//        return Data.shared.squads[index]
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        if let squad = item as? SuperheroSquad {
//            return squad.members.count > 0
//        }
//        return false
//    }
}

// MARK: - <NSOutlineViewDelegate>

extension MainVC: NSOutlineViewDelegate {

}



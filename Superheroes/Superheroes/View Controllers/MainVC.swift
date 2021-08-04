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
    @IBOutlet weak var historyTableView: NSTableView!

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
            let requestID = UUID()
            var request = Request(
                id: requestID,
                timestamps: Request.Timestamps(started: Date()),
                squads: squads,
                request: urlRequest,
                state: .created)
            
            model.history.append(request)

            DispatchQueue.main.async {
                self.historyTableView.reloadData()
            }
            
            API.sendRequest(request) { [self] request in
                print("callback", self, request)

                if let request = self.model.history.filter({ $0.id == requestID }).first {
                    request.state = .completed
                }

                DispatchQueue.main.async {
                    self.historyTableView.reloadData()
                }
            }
        case .failure(let error):
            fatalError("unhandled: \(error.localizedDescription)")
        }
    }
}

// MARK: - <NSTableViewDelegate>

extension MainVC: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let HistoryCell = "HistoryCell"
      }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Only a single column, so dispense with any column filtering
        if let cell = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.HistoryCell),
            owner: nil) as? HistoryCell
        {
            let item = self.model.history[row]

            cell.dateLabel?.stringValue = item.id.uuidString
            cell.statusLabel?.stringValue = item.state.rawValue
          return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let selectedRow = historyTableView.selectedRowIndexes.first {
            model.currentRequest = model.history[selectedRow]
        }
        else {
            model.currentRequest = nil
        }
        DispatchQueue.main.async {
            self.outlineView.reloadData()
            self.outlineView.expandItem(nil, expandChildren: true)
        }
    }
}

// MARK: - <NSTableViewDataSource>

extension MainVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.model.history.count
    }
}

// MARK: - <NSOutlineViewDataSource>

extension MainVC: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let squad = item as? SuperheroSquad {
            return squad.members.count
        }

        return model.currentRequest?.squads.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let squad = item as? SuperheroSquad {
            return squad.members[index]
        }

        return model.currentRequest?.squads[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let squad = item as? SuperheroSquad {
            return squad.members.count > 0
        }
        return false
    }
}

// MARK: - <NSOutlineViewDelegate>

extension MainVC: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let view = outlineView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier("KeyCell"),
            owner: self) as? NSTableCellView
        {
            if let squad = item as? SuperheroSquad {
                view.textField?.stringValue = squad.squadName
            }
            else if let hero = item as? Member {
                view.textField?.stringValue = hero.name
            }

            return view

        }

        return nil
    }
}



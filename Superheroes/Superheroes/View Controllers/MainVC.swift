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

    // Relatively expensive so create only once
    private let dateFormatter = DateFormatter()

    private var model: MainVCViewModel = MainVCViewModel()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "yyyy/MM/dd, HH:mm:ss"
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
        let squads = Data.createSquads(maxSquads: 5, maxMembers: 5)
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

                // NOTE: artifical delay to help show async update of table
                sleep(UInt32.random(in: 0...2))

                if let request = self.model.history.filter({ $0.id == requestID }).first {
                    request.state = .completed
                    request.timestamps.completed = Date()
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

// MARK: - Shared UI Item Identifiers

extension MainVC {
    fileprivate enum CellIdentifiers {
        static let HistoryCellID = NSUserInterfaceItemIdentifier(rawValue: "HistoryCell")
        static let KeyCellID = NSUserInterfaceItemIdentifier("KeyCell")
        static let KeyColumnID = NSUserInterfaceItemIdentifier("KeyColumn")
        static let ValueColumnID = NSUserInterfaceItemIdentifier("ValueColumn")
    }
}

// MARK: - <NSTableViewDelegate>

extension MainVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Only a single column, so dispense with any column filtering
        if let cell = tableView.makeView(
            withIdentifier: CellIdentifiers.HistoryCellID,
            owner: nil) as? HistoryCell
        {
            let item = self.model.history[row]

            var dateString = ""
            if let started = item.timestamps.started {
                dateString = "Started: \(dateFormatter.string(from: started))"
            }

            if let completed = item.timestamps.completed{
                dateString += " - Completed: \(dateFormatter.string(from: completed))"
            }

            cell.dateLabel?.stringValue = dateString
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

        switch item {
        case nil:
            return model.currentRequest?.squads.count ?? 0
        case is SuperheroSquad:
            return 5
        case is Member:
            return 3
        case let members as [Member]:
            return members.count
        default:
            return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let squad = item as? SuperheroSquad {

            // This style vs. a switch... Undecided which is clearer
            return [
                ("id",        "\(squad.id)"),
                ("Home Town", "\(squad.homeTown)"),
                ("Formed in", "\(squad.formed)"),
                ("Active",    "\(squad.active ? "Yes" : "No")"),
                squad.members,
            ][index]
        }

        else if let members = item as? [Member] {
            return members[index]
        }

        else if let member = item as? Member {
            return [
                ("Age",             "\(member.age) years old"),
                ("Secret Identity", "\(member.secretIdentity)"),
                // Explicitly avoiding another level of outline since we're quite deep already.
                // Hopefully this delegate code shows off the idea sufficiently
                ("Powers",          member.powers.joined(separator: ", ")),
            ][index]
        }

        return model.currentRequest?.squads[index] as Any
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is SuperheroSquad
            || item is [Member]
            || item is Member
    }
}

// MARK: - <NSOutlineViewDelegate>

extension MainVC: NSOutlineViewDelegate {

    typealias StringKeyValue = (String, String)

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }

        var textFieldValue = ""


        if let view = outlineView.makeView(
            withIdentifier: CellIdentifiers.KeyCellID,
            owner: self) as? NSTableCellView
        {
            switch item {
            case let squad as SuperheroSquad:
                if columnIdentifier == CellIdentifiers.KeyColumnID {
                    textFieldValue = squad.squadName
                }

            case is [Member]:
                if columnIdentifier == CellIdentifiers.KeyColumnID {
                    textFieldValue = "Members"
                }

            case let member as Member:
                if columnIdentifier == CellIdentifiers.KeyColumnID {
                    textFieldValue = "\(member.name)"
                }

            // Using StringKeyValue allows generic reuse
            case let (key, value) as StringKeyValue:
                switch columnIdentifier {
                case CellIdentifiers.KeyColumnID:
                    textFieldValue = key
                case CellIdentifiers.ValueColumnID:
                    textFieldValue = value
                default:
                    break
                }

            default:
                break
            }

            view.textField?.stringValue = textFieldValue

            return view
        }

        return nil
    }
}

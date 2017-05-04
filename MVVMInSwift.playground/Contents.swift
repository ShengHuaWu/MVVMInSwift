import UIKit
import PlaygroundSupport

extension Array where Element: Comparable {
    func upperBoundary(of key: Element) -> Index {
        var low = startIndex
        var high = endIndex
        while low < high {
            let mid = low + (high - low) / 2
            if self[mid] <= key {
                low = mid + 1
            } else {
                high = mid
            }
        }
        
        return low
    }
}

struct State {
    enum EditingStyle {
        case insert(Int, IndexPath)
        case delete(IndexPath)
        case none
    }
    
    private var sortedItems: [Int]
    var editingStyle: EditingStyle {
        didSet {
            switch editingStyle {
            case let .insert(new, indexPath):
                sortedItems.insert(new, at: indexPath.row)
            case let .delete(indexPath):
                sortedItems.remove(at: indexPath.row)
            default:
                break
            }
        }
    }
    
    var count: Int {
        return sortedItems.count
    }
    
    init(sortedItems: [Int]) {
        self.sortedItems = sortedItems
        self.editingStyle = .none
    }
    
    func text(at indexPath: IndexPath) -> String {
        return "\(sortedItems[indexPath.row])"
    }
    
    func upperBoundary(of item: Int) -> Int {
        return sortedItems.upperBoundary(of: item)
    }
}

final class DemoViewModel {
    var state = State(sortedItems: [1, 2, 3]) {
        didSet {
            callback(state)
        }
    }
    let callback: (State) -> ()
    
    init(callback: @escaping (State) -> ()) {
        self.callback = callback
    }
    
    func addNewItem() {
        let item = Int(arc4random_uniform(10))
        let insertionIndex = state.upperBoundary(of: item)
        state.editingStyle = .insert(item, IndexPath(row: insertionIndex, section: 0))
    }
    
    func removeItem(at indexPath: IndexPath) {
        state.editingStyle = .delete(indexPath)
    }
}

final class DemoViewController: UITableViewController {
    fileprivate var viewModel: DemoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNumber))
        navigationItem.rightBarButtonItem = addButtonItem
        
        viewModel = DemoViewModel { [unowned self] (state) in
            switch state.editingStyle {
            case .none:
                self.tableView.reloadData()
            case let .insert(_, indexPath):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            case let .delete(indexPath):
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    func addNumber() {
        viewModel.addNewItem()
    }
}

extension DemoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel != nil ? viewModel.state.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.textLabel?.text = viewModel.state.text(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        viewModel.removeItem(at: indexPath)
    }
}

let demoVC = DemoViewController(style: .plain)
let navigationController = UINavigationController(rootViewController: demoVC)
navigationController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
PlaygroundPage.current.liveView = navigationController.view

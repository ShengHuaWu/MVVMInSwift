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

final class DemoViewController: UITableViewController {
    fileprivate var sortedItems = [1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNumber))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func addNumber() {
        let number = Int(arc4random_uniform(10))
        let insertionIndex = sortedItems.upperBoundary(of: number)
        sortedItems.insert(number, at: insertionIndex)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: insertionIndex, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension DemoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.textLabel?.text = "\(sortedItems[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        sortedItems.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}

let demoVC = DemoViewController(style: .plain)
let navigationController = UINavigationController(rootViewController: demoVC)
navigationController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
PlaygroundPage.current.liveView = navigationController.view
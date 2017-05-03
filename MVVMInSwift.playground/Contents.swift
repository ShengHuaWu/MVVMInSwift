import UIKit
import PlaygroundSupport

final class DemoViewController: UITableViewController {
    fileprivate var items = [1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNumber))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func addNumber() {
        let number = Int(arc4random_uniform(10))
        items.append(number)
        items = items.sorted()
        tableView.reloadData()
    }
}

extension DemoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        items.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}

let demoVC = DemoViewController(style: .plain)
let navigationController = UINavigationController(rootViewController: demoVC)
navigationController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
PlaygroundPage.current.liveView = navigationController.view
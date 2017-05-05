## MVVM in Swift
![mvvm-diagram]()
MVVM is an augmented version of MVC architecture where we formally connect our view and controller, and move business logic out of the controller and into the view model.
MVVM may sound complicated, but it’s essentially a dressed-up version of the MVC architecture that you’re already familiar with.
Generally speaking, MVVM is often combined with Functional Reactive Programming and there are a lot of FRP libraries, such as [RxSwift](https://github.com/ReactiveX/RxSwift) and [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).
However, if someone isn't familiar with FRP, it's still possible to leverage MVVM in a project.
In this article, I will demonstrate how to adopt MVVM without FRP libraries.

### Model View Controller
Let's get started with the standard MVC approach.
The example is to display an array of sorted integers within a `UITableView`.
In addition, we are able to insert a new integer into the correct order by clicking the add button on the top right and delete an integer by swiping right a row as well.
![table-view]()
I just create a `UITableViewController` subclass called `DemoViewController` and implement the logic and `UITableViewDataSource` within it.
```
final class DemoViewController: UITableViewController {
    fileprivate var sortedIntegers = [1, 2, 3]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())

        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewInteger))
        navigationItem.rightBarButtonItem = addButtonItem
    }

    func addNewInteger() {
        let number = Int(arc4random_uniform(10))
        let insertionIndex = sortedIntegers.upperBoundary(of: number)
        sortedIntegers.insert(number, at: insertionIndex)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: insertionIndex, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension DemoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedIntegers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.textLabel?.text = "\(sortedIntegers[indexPath.row])"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        sortedIntegers.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
```

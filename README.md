## MVVM in Swift
![mvvm-diagram](https://github.com/ShengHuaWu/MVVMInSwift/blob/master/Resources/MVVM-diagram.png)
MVVM is an augmented version of MVC architecture where we formally connect our view and controller, and move the business logic out of the controller and into the view model.
MVVM may sound complicated, but it’s essentially a dressed-up version of the MVC architecture that you’re already familiar with.
Generally speaking, MVVM is often combined with Functional Reactive Programming and there are a lot of FRP libraries, such as [RxSwift](https://github.com/ReactiveX/RxSwift) and [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).
However, if someone isn't familiar with FRP, it's still possible to leverage MVVM in a project.
In this article, I will demonstrate how to adopt MVVM without FRP libraries.

### Model View Controller
Let's get started with the standard MVC approach and the example is to display an array of sorted integers within a `UITableView`.
In addition, we are able to insert a new integer into the correct order by clicking the add button on the top right and delete an integer by swiping a row as well.

![table-view](https://github.com/ShengHuaWu/MVVMInSwift/blob/master/Resources/tableview.png)

Here, I just create a `UITableViewController` subclass called `DemoViewController` and implement the logic and `UITableViewDataSource` within it.
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

### Model View View Model
The first step of converting to MVVM is to create a `struct` called `State` and it stores the information related with the table view, in our case, the sorted integers.
```
struct State {
    private(set) var sortedIntegers: [Int]

    func text(at indexPath: IndexPath) -> String {
        return "\(sortedIntegers[indexPath.row])"
    }
}
```
Because the table view should be updated after inserting or deleting an integer, let's write an `enum` called `EditingStyle` and it contains `insert`,  `delete` and `none` cases.
Furthermore, we create an `editingStyle` property in `State` and update the `sortedIntegers` property with [Swift's property observers](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html) feature on the `editingStyle` property.
```
struct State {
    enum EditingStyle {
        case insert(Int, IndexPath)
        case delete(IndexPath)
        case none
    }

    var editingStyle: EditingStyle {
        didSet {
            switch editingStyle {
            case let .insert(new, indexPath):
                sortedIntegers.insert(new, at: indexPath.row)
            case let .delete(indexPath):
                sortedIntegers.remove(at: indexPath.row)
            default:
                break
            }
        }
    }

    // ...
}
```
Now, we are comfortable to create our view model class and it includes the insertion and deletion logic.
Besides, our view controller can only access the information of `State` via our view model.
If the information of `State` is changed, our view controller can update its table view through a callback closure of our view model as well.
```
final class DemoViewModel {
    private(set) var state = State(sortedIntegers: [1, 2, 3]) {
        didSet {
            callback(state)
        }
    }
    let callback: (State) -> ()

    init(callback: @escaping (State) -> ()) {
        self.callback = callback
    }

    func addNewInteger() {
        let integer = Int(arc4random_uniform(10))
        let insertionIndex = state.sortedIntegers.upperBoundary(of: integer)
        state.editingStyle = .insert(integer, IndexPath(row: insertionIndex, section: 0))
    }

    func removeInteger(at indexPath: IndexPath) {
        state.editingStyle = .delete(indexPath)
    }
}
```
Finally, we modify the code inside our view controller to hook everything up.
```
final class DemoViewController: UITableViewController {
    fileprivate var viewModel: DemoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())

        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewInteger))
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

    func addNewInteger() {
        viewModel?.addNewInteger()
    }
}

extension DemoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.state.sortedIntegers.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.textLabel?.text = viewModel?.state.text(at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        viewModel?.removeInteger(at: indexPath)
    }
}
```

### Conclusion
The sample playground is [here](https://github.com/ShengHuaWu/MVVMInSwift) and this article is inspired by [objc.io Swift Talk](https://talk.objc.io/episodes/S01E47-view-models-at-kickstarter).

There are several merits of adopting MVVM in your project.
First of all, it makes the codebase more testable.
The view controller always has a bad reputation of testing but moving all business logic into the view model gives the convenience and possibility of writing tests for the logic.
Secondly, following this pattern can make the codebase more consistent and brings more readability.
Moreover, it's possible to further reduce the complexity of UI binding and asynchronous chaining with FRP libraries.
I'm totally open to discussion and feedback, so please share your thoughts. Thank you!

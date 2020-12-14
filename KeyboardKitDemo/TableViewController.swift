// Douglas Hill, May 2019

import UIKit
import KeyboardKit

class TableViewController: FirstResponderViewController, UITableViewDataSource, UITableViewDelegate {
    override init() {
        super.init()
        title = "Table View"
        tabBarItem.image = UIImage(systemName: "list.bullet")
    }

    private let cellReuseIdentifier = "a"
    private lazy var tableView = KeyboardTableView()

    override func loadView() {
        view = tableView
    }

    var bookmarksBarButtonItem: KeyboardBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        bookmarksBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .bookmarks, target: nil, action: #selector(showBookmarks))

        let testItem = KeyboardBarButtonItem(title: "Alert", style: .plain, target: nil, action: #selector(testAction))
        testItem.keyEquivalent = ([.command, .alternate], "t")
        navigationItem.rightBarButtonItems = [testItem, bookmarksBarButtonItem!]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // UIRefreshControl is not available when optimised for Mac. Crashes at runtime.
        // https://steipete.com/posts/forbidden-controls-in-catalyst-mac-idiom/
        if traitCollection.userInterfaceIdiom != .mac {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }

    private static let freshData: [String] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut

        var d: [String] = []
        for index in 0..<50 {
            d.append(formatter.string(from: NSNumber(value: index + 1))!)
        }
        return d
    }()

    private var data: [String] = freshData

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Section \(section + 1)"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(TableViewController(), animated: true)
    }

    @objc private func testAction(_ sender: Any?) {
        let alert = UIAlertController(title: "This is a test", message: "You can show this alert either by tapping the bar button or by pressing command + option + T.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    @objc private func showBookmarks(_ sender: Any?) {
        let bookmarksViewController = BookmarksViewController()
        let navigationController = KeyboardNavigationController(rootViewController: bookmarksViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = bookmarksBarButtonItem
        present(navigationController, animated: true)
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data = TableViewController.freshData
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        precondition(editingStyle == .delete)

        data.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

class BookmarksViewController: FirstResponderViewController {
    override init() {
        super.init()
        title = "Bookmarks"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(saveBookmarks))

        view.backgroundColor = .systemBackground
    }

    @objc private func saveBookmarks(_ sender: Any?) {
        presentingViewController?.dismiss(animated: true)
    }
}

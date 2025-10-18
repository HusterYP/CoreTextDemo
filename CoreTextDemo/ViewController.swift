//
//  ViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit

import UIKit

class ViewController: UIViewController {
    var datasource: [(String, () -> UIViewController)] = [
        ("CTFramesetter: DynamicHeight", { DynamicHeightViewController() }),
        ("CTFramesetter: CircularText", { CircularTextViewController() }),
        ("CTFramesetter: MultiColumn", { MultiColumnViewController() }),
        ("CTFrame: Basic", { BasicFrameViewController() }),
        ("CTFrame: CustomLine", { CustomLineDrawViewController() }),
        ("CTFrame: HitTestable", { HitTestableFrameViewController() })
    ]
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CoreText Examples"
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    private var titles: [String] {
        return datasource.map({ $0.0 })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let title = titles[indexPath.row]
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let creator = datasource[indexPath.row].1
        let vc = creator()
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
}

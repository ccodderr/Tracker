//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filterType: FilterType)
}

final class FiltersViewController: UIViewController {
    // MARK: - Properties
    private let selectedFilter: FilterType
    weak var delegate: FiltersViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FiltersCell.self, forCellReuseIdentifier: "FiltersCell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return tableView
    }()
    
    // MARK: - Initialization
    init(selectedFilter: FilterType) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        [
            titleLabel,
            tableView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(FilterType.allCases.count * 75)),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        FilterType.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersCell", for: indexPath) as? FiltersCell,
              let filterType = FilterType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        let isSelected = filterType == selectedFilter
        cell.configure(title: filterType.title, isSelected: isSelected)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let filterType = FilterType(rawValue: indexPath.row) else { return }
        
        delegate?.didSelectFilter(filterType)
        dismiss(animated: true)
    }
}

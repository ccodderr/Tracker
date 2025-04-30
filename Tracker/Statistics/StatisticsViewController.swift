//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import UIKit

protocol StatisticsViewControllerProtocol: AnyObject {
    var presenter: StatisticsPresenterProtocol? { get set }
    func updateUIState(_ hasData: Bool)
    func reloadStatistics()
}

final class StatisticsViewController: UIViewController, StatisticsViewControllerProtocol {
    var presenter: StatisticsPresenterProtocol?
    
    private let emptyStateImageView = UIImageView(image: UIImage(named: "statisticsEmptyImage"))
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "Анализировать пока нечего"
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: "StatisticsCell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private enum StatisticType: Int, CaseIterable {
        case bestPeriod
        case perfectDays
        case completedTrackers
        case averageValue
        
        var title: String {
            switch self {
            case .bestPeriod: "Лучший период"
            case .perfectDays: "Идеальные дни"
            case .completedTrackers: "Трекеров завершено"
            case .averageValue: "Среднее значение"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewDidLoad()
    }
    
    func updateUIState(_ hasData: Bool) {
        emptyStateImageView.isHidden = hasData
        emptyStateLabel.isHidden = hasData
        tableView.isHidden = !hasData
    }
    
    func reloadStatistics() {
        tableView.reloadData()
    }
    
    //   MARK: Private methods
    private func setupNavigationBar() {
        navigationController?.toolbar.backgroundColor = .ypWhite
        navigationItem.title = .localized.localized.statisticsTitle
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor.ypBlack
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupLayout() {
        view.backgroundColor = .ypWhite
        
        [
            emptyStateImageView,
            emptyStateLabel,
            tableView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 10),
            
            tableView.heightAnchor.constraint(equalToConstant: 420),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }
    
    private func getValueForStatistic(_ type: StatisticType) -> String {
        guard let presenter = presenter else { return "0" }
        
        switch type {
        case .bestPeriod:
            return "\(presenter.calculateBestPeriod())"
        case .perfectDays:
            return "\(presenter.calculatePerfectDays())"
        case .completedTrackers:
            return "\(presenter.calculateCompletedTrackers())"
        case .averageValue:
            return "\(presenter.calculateAverageCompletions())"
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        StatisticType.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell", for: indexPath) as? StatisticsCell,
              let statisticType = StatisticType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configure(title: statisticType.title, value: getValueForStatistic(statisticType))
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 102
    }
}

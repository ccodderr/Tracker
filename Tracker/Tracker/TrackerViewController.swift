//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import UIKit

protocol TrackerViewControllerProtocol: AnyObject {
    var presenter: TrackerPresenterProtocol? { get set }
}

final class TrackerViewController: UIViewController {
    var presenter: TrackerPresenterProtocol?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.layer.cornerRadius = 10
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchBar.searchTextField.backgroundColor = UIColor.ypGray.withAlphaComponent(0.12)
        searchBar.searchTextField.leftViewMode = .always
        searchBar.searchTextField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchBar.searchTextField.leftView?.tintColor = .ypGray
        return searchBar
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyStateImage")
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ypBlack
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor.ypBlack
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Кнопка "+"
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton
        
        // Кнопка с датой
        updateDateButton(with: Date())
    }
    
    @objc private func addButtonTapped() {
        // Действие при нажатии на "+"
    }
    
    private func updateDateButton(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = " dd.MM.yy "
        let dateString = formatter.string(from: date)
        
        let dateButton = UIButton(type: .system)
        dateButton.setTitle(dateString, for: .normal)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.backgroundColor = UIColor.ypGray.withAlphaComponent(0.12)
        dateButton.layer.cornerRadius = 8
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        let dateBarButton = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = dateBarButton
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        [
            searchBar,
            emptyStateImageView,
            emptyStateLabel
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
    }
}

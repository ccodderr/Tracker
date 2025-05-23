//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var presenter: TrackersPresenterProtocol? { get set }
    func updateTrackers(
        _ categories: [TrackerCategory]
    )
    func reloadTrackers()
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    // MARK: - Properties
    var presenter: TrackersPresenterProtocol?
    private var categories: [TrackerCategory] = []
    private let trackerStore = TrackerStore()

    private var currentDate: Date = Date() {
        didSet {
            updateEmptyStateVisibility()
            collectionView.reloadData()
        }
    }
    
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
    
    private let emptyStateImageView = UIImageView(image: UIImage(resource: .emptyState))
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            TextSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TextSectionHeader.reuseIdentifier
        )
        return collectionView
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
        updateEmptyStateVisibility()
        presenter?.view = self
        presenter?.viewDidLoad()
    }

//   MARK: Private methods
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor.ypBlack
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupLayout() {
        view.backgroundColor = .ypWhite
        
        [
            searchBar,
            emptyStateImageView,
            emptyStateLabel,
            collectionView
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
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 10),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        let isCollectionEmpty = categories.isEmpty
        
        if isCollectionEmpty {
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    func updateTrackers(
        _ categories: [TrackerCategory]
    ) {
        self.categories = categories
        updateEmptyStateVisibility()
        collectionView.reloadData()
    }
    
    func reloadTrackers() {
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }
    
    @objc private func addButtonTapped() {
        let trackerVC = TrackerTypeViewController()
        trackerVC.modalPresentationStyle = .pageSheet
        trackerVC.delegate = self
        present(trackerVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        presenter?.dateChanged(to: sender.date)
        currentDate = sender.date
        sender.removeFromSuperview()
    }
}

extension TrackersViewController: HabitCreationDelegate {
    func didCreate(_ habit: Tracker) {
        presenter?.addTracker(habit)
    }
    
    func addTracker(_ tracker: Tracker, toCategory category: String) {
        try? trackerStore.addTracker(tracker)
    }

}

// MARK: - UICollectionView DataSource & Delegate

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TextSectionHeader.reuseIdentifier,
                for: indexPath) as? TextSectionHeader else {
                return UICollectionReusableView()
            }
            
            let title = categories[indexPath.section].title
            header.configure(with: title)
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TrackerCell",
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = presenter?.isTrackerCompleted(tracker, date: currentDate) ?? false
        let isEditable = presenter?.isEditableDate(currentDate) ?? false
        let countOfDays = presenter?.getCompletedTrackerCount(tracker) ?? .zero
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            isEditable: isEditable,
            countOfDays: countOfDays,
            onToggle: { [weak self] in
                self?.presenter?.toggleTrackerCompletion(
                    tracker,
                    on: self?.currentDate ?? Date()
                )
            }
        )
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 32, height: 148)
    }
}

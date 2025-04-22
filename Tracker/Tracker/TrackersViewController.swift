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
    func presentEditScreen(for tracker: Tracker)
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    // MARK: - Properties
    var presenter: TrackersPresenterProtocol?
    private var categories: [TrackerCategory] = []
    private let trackerStore = TrackerStore()
    private var visibleCategories: [TrackerCategory] = []

    private var currentDate: Date = Date() {
        didSet {
            updateEmptyStateVisibility()
            collectionView.reloadData()
        }
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = .localized.localized.searchTitle
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
        label.text = .localized.localized.emptyStateTitle
        label.textColor = .ypBlack
        return label
    }()
    
    private let searchEmptyImageView = UIImageView(image: UIImage(named: "searchEmptyImage"))
    
    private let searchEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12)
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
        searchBar.delegate = self
    }

//   MARK: Private methods
    private func setupNavigationBar() {
        navigationItem.title = .localized.localized.trackersTitle
        
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
            searchEmptyImageView,
            searchEmptyLabel,
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
            
            searchEmptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchEmptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchEmptyImageView.widthAnchor.constraint(equalToConstant: 80),
            searchEmptyImageView.heightAnchor.constraint(equalToConstant: 80),

            searchEmptyLabel.topAnchor.constraint(equalTo: searchEmptyImageView.bottomAnchor, constant: 8),
            searchEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        let isFiltered = !(searchBar.text ?? "").isEmpty
        let isEmpty = visibleCategories.isEmpty

        emptyStateImageView.isHidden = isFiltered || !isEmpty
        emptyStateLabel.isHidden = isFiltered || !isEmpty

        searchEmptyImageView.isHidden = !isFiltered || !isEmpty
        searchEmptyLabel.isHidden = !isFiltered || !isEmpty

        collectionView.isHidden = isEmpty
    }
    
    func updateTrackers(
        _ categories: [TrackerCategory]
    ) {
        self.categories = categories
        self.visibleCategories = categories
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
    
    func presentEditScreen(for tracker: Tracker) {
        let type: TrackerType = tracker.schedule.isEmpty
        ? .irregularEvent
        : .habit
        
        let editVC = HabitCreationViewController(
            trackerType: type,
            tracker: tracker
        )
        editVC.delegate = self
        present(editVC, animated: true)
    }
    
    private func presentDeleteAlert(for tracker: Tracker) {
        let alert = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: .localized.localized.deleteTitle, style: .destructive) { [weak self] _ in
            self?.presenter?.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(title: .localized.localized.cancelTitle, style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

extension TrackersViewController: HabitCreationDelegate {
    func didUpdate(_ tracker: Tracker) {
        presenter?.updateTracker(tracker)
    }
    
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
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
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
            
            let title = visibleCategories[indexPath.section].title
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
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]

        
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

// MARK: - TrackersViewController: contextMenuConfiguration
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard indexPath.section < visibleCategories.count,
              indexPath.row < visibleCategories[indexPath.section].trackers.count else {
            return nil
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let pinTitle = tracker.isPinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                self?.presenter?.togglePin(for: tracker)
            }

            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.presenter?.editTracker(tracker)
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.presentDeleteAlert(for: tracker)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            visibleCategories = categories
            updateEmptyStateVisibility()
            collectionView.reloadData()
            return
        }

        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        updateEmptyStateVisibility()
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        visibleCategories = categories
        updateEmptyStateVisibility()
        collectionView.reloadData()
    }
}

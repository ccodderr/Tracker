//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import UIKit

// MARK: - CategoryListViewController
final class CategoryListViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: CategoryListViewModel
    private var onCategorySelected: ((CategoryCoreData?) -> Void)?
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized.localized.categoryTitle
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .emptyState)
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized.localized.categoryEmptyState
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        return view
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.localized.localized.categoryAddButton, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: CategoryListViewModel, onCategorySelected: @escaping (CategoryCoreData?) -> Void) {
        self.viewModel = viewModel
        self.onCategorySelected = onCategorySelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        setupActions()
        viewModel.loadCategories()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 23),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            emptyStateView.heightAnchor.constraint(equalTo: tableView.heightAnchor),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.emptyStateView.isHidden = self.viewModel.numberOfCategories() > 0
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let addCategoryVC = EditCategoryViewController(
            viewModel: viewModel,
            categoryIndex: nil,
            onDismiss: { [weak self] in
                self?.viewModel.loadCategories()
            }
        )
        present(addCategoryVC, animated: true)
    }
    
    private func editCategory(at indexPath: IndexPath) {
        let editVC = EditCategoryViewController(
            viewModel: viewModel,
            categoryIndex: indexPath.row,
            onDismiss: { [weak self] in
                self?.viewModel.loadCategories()
            }
        )
        present(editVC, animated: true)
    }
    
    private func presentDeleteAlert(for index: Int) {
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: .localized.localized.deleteTitle, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        }

        let cancelAction = UIAlertAction(title: .localized.localized.cancelTitle, style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell,
              let category = viewModel.getCategory(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let isSelected = indexPath.row == viewModel.getSelectedCategoryIndex()
        let isLast = indexPath.row == viewModel.numberOfCategories() - 1
        cell.configure(with: category, isSelected: isSelected, isLast: isLast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(
       _ tableView: UITableView,
       contextMenuConfigurationForRowAt indexPath: IndexPath,
       point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let provider: UIContextMenuActionProvider = { _ in
            UIMenu(title: "", children: [
                UIAction(title: .localized.localized.editTitle) { [weak self] _ in
                    self?.editCategory(at: indexPath)
                },
                UIAction(title: .localized.localized.deleteTitle, attributes: .destructive) { [weak self] _ in
                    self?.presentDeleteAlert(for: indexPath.row)
                }
            ])
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: provider)
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
        
        guard let category = viewModel.dbCategoryAt(index: indexPath.row)
        else { return }
        
        onCategorySelected?(category)
    }
}

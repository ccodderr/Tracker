//
//  EditCategory.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import UIKit

final class EditCategoryViewController: UIViewController {
    private let viewModel: CategoryListViewModel
    private var onDismiss: (() -> Void)?
    private var categoryIndex: Int?
    private var isCategoryEditing: Bool {
        return categoryIndex != nil
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .ypBlack
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = .localized.localized.categoryInputPlaceholder
        textField.leftView = UIView(frame: .init(origin: .zero, size: .init(width: 15, height: 1)))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackground
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.localized.localized.doneTitle, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: CategoryListViewModel, categoryIndex: Int? = nil, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.categoryIndex = categoryIndex
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        configureTitleAndText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 23),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func configureTitleAndText() {
        if isCategoryEditing {
            titleLabel.text = .localized.localized.categoryEditTitle
            if let index = categoryIndex, let category = viewModel.getCategory(at: index) {
                textField.text = category.title
            }
        } else {
            titleLabel.text = .localized.localized.newCategoryTitle
        }
        
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let isTextEmpty = textField.text?.isEmpty ?? true
        doneButton.isEnabled = !isTextEmpty
        doneButton.backgroundColor = isTextEmpty ? .ypGray : .ypBlack
        doneButton.setTitleColor(isTextEmpty ? .white : .ypWhite, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        
        if let index = categoryIndex {
            viewModel.updateCategory(at: index, newTitle: title)
        } else {
            viewModel.addNewCategory(title: title)
        }
        
        dismiss(animated: true, completion: onDismiss)
    }
}

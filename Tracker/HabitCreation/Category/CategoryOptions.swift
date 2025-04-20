//
//  CategoryOptions.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import UIKit

final class CategoryOptionsViewController: UIViewController {
    // MARK: - Properties
    private let category: Category
    private let viewModel: CategoryListViewModel
    private let index: Int
    private var onDismiss: (() -> Void)?
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Редактировать", for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить", for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    private let separatorView1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let separatorView2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // MARK: - Initialization
    init(category: Category, viewModel: CategoryListViewModel, index: Int, onDismiss: @escaping () -> Void) {
        self.category = category
        self.viewModel = viewModel
        self.index = index
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        configureViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(separatorView1)
        containerView.addSubview(editButton)
        containerView.addSubview(separatorView2)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            checkmarkImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            separatorView1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView1.heightAnchor.constraint(equalToConstant: 0.5),
            
            editButton.topAnchor.constraint(equalTo: separatorView1.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            
            separatorView2.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 0),
            separatorView2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView2.heightAnchor.constraint(equalToConstant: 0.5),
            
            deleteButton.topAnchor.constraint(equalTo: separatorView2.bottomAnchor, constant: 24),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func configureViews() {
        titleLabel.text = category.title
        checkmarkImageView.isHidden = viewModel.getSelectedCategoryIndex() != index
    }
    
    // MARK: - Actions
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: onDismiss)
    }
    
    @objc private func editButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            let editVC = EditCategoryViewController(
                viewModel: self.viewModel,
                categoryIndex: self.index
            ) {
                self.onDismiss?()
            }
            
            let presentingVC = self.presentingViewController
            presentingVC?.present(editVC, animated: true)
        }
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.viewModel.deleteCategory(at: self.index)
            self.onDismiss?()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CategoryOptionsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension CategoryOptionsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - BottomSheetPresentationController
class BottomSheetPresentationController: UIPresentationController {
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmedView.frame = containerView.bounds
        containerView.addSubview(dimmedView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmedView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmedView.alpha = 0
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        let height = containerView.bounds.height * 0.3
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height,
            width: containerView.bounds.width,
            height: height
        )
    }
}

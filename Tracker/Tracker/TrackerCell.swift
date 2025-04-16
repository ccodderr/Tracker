//
//  TrackerCell.swift
//  Tracker
//
//  Created by Yana Silosieva on 11.03.2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    private lazy var emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.text = "🌿"
        emoji.textAlignment = .center
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emoji.font = .systemFont(ofSize: 16, weight: .regular)
        return emoji
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.addSubview(emojiLabel)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            emojiLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 4)
        ])
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSelection1
        view.layer.cornerRadius = 16
        view.addSubview(titleLabel)
        view.addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
        ])
        return view
    }()
    
    private var countOfDays: Int = 0
    
    private lazy var countOfDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "\(countOfDays) день"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.backgroundColor = .colorSelection1
        button.layer.cornerRadius = 17
        
        button.imageView?.tintColor = .white
        return button
    }()
    
    private var onToggle: (() -> Void)?
    private var isCompleted: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [
            mainView,
            button,
            countOfDaysLabel
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -8),
            
            countOfDaysLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0),
            countOfDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 34),
            button.widthAnchor.constraint(equalToConstant: 34),
            
        ])
    }
        
    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        isEditable: Bool,
        onToggle: @escaping () -> Void
    ) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        mainView.backgroundColor = tracker.color.wrappedValue
        self.onToggle = onToggle
        self.isCompleted = isCompleted
        updateUI()
        button.isEnabled = isEditable
    }

    private func updateUI() {
        let iconName = isCompleted ? "checkmark" : "plus"
        button.setImage(UIImage(systemName: iconName), for: .normal)
        countOfDaysLabel.text = "\(countOfDays) день" + (countOfDays == 1 ? "" : "я")
    }
    
    @objc private func buttonTapped() {
        isCompleted.toggle()
        
        if isCompleted {
            countOfDays += 1
        } else {
            countOfDays = max(0, countOfDays - 1)
        }

        updateUI()
        onToggle?()
    }
}

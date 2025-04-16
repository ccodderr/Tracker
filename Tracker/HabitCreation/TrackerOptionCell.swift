//
//  TrackerOptionCell.swift
//  Tracker
//
//  Created by Yana Silosieva on 08.03.2025.
//

import UIKit

final class TrackerOptionCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .ypLightGray.withAlphaComponent(0.3)

        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Конфигурация ячейки
    func configure(title: String, value: String?, isLastCell: Bool, isSingleCell: Bool) {
        titleLabel.text = title
        
        if isLastCell || isSingleCell {
            separatorInset = UIEdgeInsets(
                top: 0,
                left: bounds.width,
                bottom: 0,
                right: 0
            )
        } else {
            separatorInset = UIEdgeInsets(
                top: 0,
                left: 15,
                bottom: 0,
                right: 0
            )
        }
    }
}

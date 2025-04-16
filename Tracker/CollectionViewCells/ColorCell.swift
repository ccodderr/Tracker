//
//  ColorCell.swift
//  Tracker
//
//  Created by Yana Silosieva on 25.02.2025.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    static let identifier = "ColorCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        containerView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            colorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            colorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            colorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
        ])
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
            containerView.layer.borderWidth = 3
            containerView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

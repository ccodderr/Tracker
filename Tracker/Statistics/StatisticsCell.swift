//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.04.2025.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    static let reuseIdentifier = "StatisticsCell"
    private var lastGradientBounds: CGRect = .zero
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        backgroundColor = .ypWhite
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
        
        DispatchQueue.main.async {
            self.containerView.addGradientBorder(
                colors: [
                    UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1.0),
                    UIColor(red: 0.27, green: 0.90, blue: 0.61, alpha: 1.0),
                    UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1.0)
                ],
                borderWidth: 1,
                cornerRadius: 16
            )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }

    // MARK: - Layout
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

extension UIView {
    func addGradientBorder(
        colors: [UIColor],
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 0
    ) {
        
        self.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorder"
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = colors.map { $0.cgColor }
        
        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shape
        
        self.layer.addSublayer(gradientLayer)
    }
}


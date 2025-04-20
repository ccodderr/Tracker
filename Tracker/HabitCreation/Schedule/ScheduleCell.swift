//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Yana Silosieva on 11.03.2025.
//

import UIKit


final class ScheduleCell: UITableViewCell {
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        toggleSwitch.isOn = false
        toggleSwitch.isEnabled = true
        toggleSwitch.onTintColor = .blue
        return toggleSwitch
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, toggleSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var switchChanged: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
        
        stackView.isUserInteractionEnabled = true
    }
    
    func configure(day: String, isSelected: Bool) {
        dayLabel.text = day
        toggleSwitch.isOn = isSelected
    }
    
    @objc private func switchValueChanged() {
        switchChanged?(toggleSwitch.isOn)
    }
}

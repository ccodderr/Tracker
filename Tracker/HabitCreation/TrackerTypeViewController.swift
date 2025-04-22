//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 08.03.2025.
//

import UIKit

protocol TrackerTypeDelegate: AnyObject {
    func didCreate(_ habit: Tracker)
}

final class TrackerTypeViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = .localized.localized.trackerCreationTitle
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = createButton(withTitle: .localized.localized.trackerTypeHabit)
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = createButton(withTitle: .localized.localized.trackerTypeIrregularEvent)
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: HabitCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        [
            titleLabel,
            habitButton,
            eventButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        return button
    }
    
    @objc private func habitButtonTapped() {
        let trackerVC = HabitCreationViewController(
            trackerType: .habit,
            tracker: nil
        )
        trackerVC.modalPresentationStyle = .pageSheet
        trackerVC.delegate = delegate
        present(trackerVC, animated: true)
    }
    
    @objc private func eventButtonTapped() {
        let trackerVC = HabitCreationViewController(
            trackerType: .irregularEvent,
            tracker: nil
        )
        trackerVC.modalPresentationStyle = .pageSheet
        trackerVC.delegate = delegate
        present(trackerVC, animated: true)
    }
}

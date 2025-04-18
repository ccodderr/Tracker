//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 11.03.2025.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [Weekdays])
}

final class ScheduleViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return doneButton
    }()

    private let weekdays: [Weekdays]
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays: [Weekdays]
    
    // MARK: - Lifecycle
    
    init(weekdays: [Weekdays], selectedDays: [Weekdays]) {
        self.weekdays = weekdays
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [
            titleLabel,
            tableView,
            doneButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.heightAnchor.constraint(equalToConstant: getTableHeight()),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func doneTapped() {
        delegate?.didSelectSchedule(selectedDays)
        dismiss(animated: true)
    }
    
    private func getTableHeight() -> CGFloat {
        let section = weekdays.count
        return CGFloat(75 * section)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
            fatalError("Не удалось получить TrackerOptionCell")
        }
        
        let day = weekdays[indexPath.row]
        
        cell.configure(day: day.rawValue, isSelected: selectedDays.contains(day))
        
        cell.switchChanged = { [weak self] isOn in
            guard let self else { return }
            
            if isOn {
                if !selectedDays.contains(day) {
                    selectedDays.append(day)
                }
            } else {
                selectedDays.removeAll { $0 == day }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

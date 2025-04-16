//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 08.03.2025.
//

import UIKit

protocol HabitCreationDelegate: AnyObject {
    func didCreate(_ habit: Tracker)
}

final class HabitCreationViewController: UIViewController {
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame: .init(origin: .zero, size: .init(width: 15, height: 1)))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerOptionCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypLightGray
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        return tableView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😢"]
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3,
        .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9,
        .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 12
        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 10
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.distribution = .fillEqually
        return horizontalStack
    }()

    
    // MARK: - Data
    private let trackerType: TrackerType
    private var selectedCategory: String?
    private var selectedSchedule: [Weekdays] = []
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    weak var delegate: HabitCreationDelegate?
    
    // MARK: - Lifecycle
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateCreateButtonState()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [
            titleLabel,
            trackerNameTextField,
            tableView,
            emojiLabel,
            emojiCollectionView,
            colorLabel,
            colorCollectionView,
            horizontalStack
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: getTableHeight()),
            
            horizontalStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            horizontalStack.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: emojiCollectionView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: emojiCollectionView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func getTableHeight() -> CGFloat {
        let section = trackerType == .habit ? 2 : 1
        return CGFloat(75 * section)
    }
    
    private func updateCreateButtonState() {
        let isFormFilled = trackerType == .habit
        ? !(trackerNameTextField.text ?? "").isEmpty && !selectedSchedule.isEmpty
        : !(trackerNameTextField.text ?? "").isEmpty
        
//      && selectedCategory != nil
        createButton.backgroundColor = isFormFilled ? .ypBlack : .gray
        createButton.isEnabled = isFormFilled
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func create() {
        let scheduleDays = selectedSchedule
            .compactMap { Weekdays(rawValue: $0.rawValue) }
        
        // Выбор эмоджи
        let selectedEmoji: String
        if let index = selectedEmojiIndex {
            selectedEmoji = emojis[index.item]
        } else {
            selectedEmoji = "📈"
        }
        
        // Выбор цвета
        let selectedColor: UIColor
        if let colorIndex = selectedColorIndex {
            selectedColor = colors[colorIndex.item]
        } else {
            selectedColor = colors.first ?? .red
        }
        
        delegate?.didCreate(
            .init(
                id: UUID(),
                title: trackerNameTextField.text ?? "",
                color: CodableColor(wrappedValue: selectedColor),
                emoji: selectedEmoji,
                schedule: scheduleDays,
                explicitDate: trackerType == .habit ? nil : Date()
            )
        )
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate & DataSource
extension HabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType == .habit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerOptionCell else {
            fatalError("Не удалось получить TrackerOptionCell")
        }
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        let isLastCell = indexPath.row == totalRows - 1
        let isSingleCell = totalRows == 1

        if indexPath.row == 0 {
            cell.configure(title: "Категория", value: selectedCategory, isLastCell: isLastCell, isSingleCell: isSingleCell)
        } else {
            let selectedScheduleString = selectedSchedule.map { $0.rawValue }.joined(separator: ", ")
            
            cell.configure(title: "Расписание", value: selectedScheduleString, isLastCell: isLastCell, isSingleCell: isSingleCell)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController(weekdays: Weekdays.allCases, selectedDays: selectedSchedule)
            scheduleVC.modalPresentationStyle = .formSheet
            scheduleVC.delegate = self
            present(scheduleVC, animated: true, completion: nil)
        }
    }
}

// MARK: - CollectionView Delegate & DataSource

extension HabitCreationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == colorCollectionView {
            return colors.count
        } else if collectionView == emojiCollectionView {
            return emojis.count
        }
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath
            ) as! ColorCell
            let isSelected = (indexPath == selectedColorIndex)
            cell.configure(with: colors[indexPath.item], isSelected: isSelected)
            return cell
        } else if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier,
                for: indexPath
            ) as! EmojiCell
            let isSelected = (selectedEmojiIndex == indexPath)
            cell.configure(with: emojis[indexPath.item], isSelected: isSelected)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            if let previousIndex = selectedColorIndex, previousIndex != indexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndex) as? ColorCell {
                    previousCell.configure(with: colors[previousIndex.item], isSelected: false)
                }
            }
            selectedColorIndex = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.configure(with: colors[indexPath.item], isSelected: true)
            }
        } else if collectionView == emojiCollectionView {
            if let previousIndex = selectedEmojiIndex, previousIndex != indexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndex) as? EmojiCell {
                    previousCell.configure(with: emojis[previousIndex.item], isSelected: false)
                }
            }
            selectedEmojiIndex = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                cell.configure(with: emojis[indexPath.item], isSelected: true)
            }
        }
    }
}

extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [Weekdays]) {
        selectedSchedule = schedule
        tableView.reloadData()
        updateCreateButtonState()
    }
}

//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 08.03.2025.
//

import UIKit

protocol HabitCreationDelegate: AnyObject {
    func didCreate(_ habit: Tracker)
    func didUpdate(_ tracker: Tracker)
}

final class HabitCreationViewController: UIViewController {
    // MARK: - UI Elements
    
    private var titleLabel: UILabel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .localized.localized.trackerNamePlaceholder
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
        label.text = .localized.localized.emojiTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😢"]
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = .localized.localized.colorTitle
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
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
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(.localized.localized.cancelTitle, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 12
        button.backgroundColor = .white
        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(.localized.localized.createTitle, for: .normal)
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
    private let tracker: Tracker?
    private let spacing: CGFloat = 5
    private var selectedSchedule: [Weekdays] = []
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var selectedCategory: CategoryCoreData?
    private var colorCollectionViewHeightConstraint: NSLayoutConstraint!
    private var emojiCollectionViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: HabitCreationDelegate?
    
    // MARK: - Lifecycle
    
    init(trackerType: TrackerType, tracker: Tracker? = nil) {
        self.trackerType = trackerType
        self.tracker = tracker
        self.titleLabel = {
            let label = UILabel()
            label.text = trackerType == .habit
            ? .localized.localized.newHabitTitle
            : .localized.localized.newIrregularEventTitle
            label.textColor = .black
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            return label
        }()
        
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
        
        if let tracker = tracker {
            populateFields(with: tracker)
            createButton.setTitle("Сохранить", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalculateCollectionsHeight()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        [
            titleLabel,
            trackerNameTextField,
            tableView,
            emojiLabel,
            emojiCollectionView,
            colorLabel,
            colorCollectionView,
            horizontalStack,
            contentView,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(horizontalStack)
    }
    
    private func setupConstraints() {
        colorCollectionViewHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 156)
        emojiCollectionViewHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 156)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: getTableHeight()),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionViewHeightConstraint,
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionViewHeightConstraint,
            
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            horizontalStack.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            horizontalStack.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            horizontalStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func recalculateCollectionsHeight() {
        let colorCollectionCellSize = getCollectionCellSize(colorCollectionView).height
        let colorRows = colors.count / 6
        colorCollectionViewHeightConstraint.constant = colorCollectionCellSize * CGFloat(colorRows)
        colorCollectionView.layoutIfNeeded()
        
        let emojiRows = emojis.count / 6
        emojiCollectionViewHeightConstraint.constant = colorCollectionCellSize * CGFloat(emojiRows)
        emojiCollectionView.layoutIfNeeded()
    }
    
    private func getTableHeight() -> CGFloat {
        let section = trackerType == .habit ? 2 : 1
        return CGFloat(75 * section)
    }
    
    private func populateFields(with tracker: Tracker) {
        trackerNameTextField.text = tracker.title
        
        if let index = emojis.firstIndex(of: tracker.emoji) {
            selectedEmojiIndex = IndexPath(item: index, section: 0)
            emojiCollectionView.selectItem(
                at: selectedEmojiIndex,
                animated: false,
                scrollPosition: []
            )
        }

        if let index = colors.firstIndex(where: { $0.hexString() == tracker.color }) {
            selectedColorIndex = IndexPath(item: index, section: 0)
            colorCollectionView.selectItem(
                at: selectedColorIndex,
                animated: false,
                scrollPosition: []
            )
        }

        selectedCategory = tracker.category
        selectedSchedule = tracker.schedule

        tableView.reloadData()
        updateCreateButtonState()
    }

    
    private func updateCreateButtonState() {
        let isFormFilled: Bool
        
        if trackerType == .habit {
            isFormFilled = !(trackerNameTextField.text ?? "").isEmpty && !selectedSchedule.isEmpty && selectedCategory != nil
        } else {
            isFormFilled = !(trackerNameTextField.text ?? "").isEmpty && selectedCategory != nil
        }
        
        createButton.backgroundColor = isFormFilled ? .ypBlack : .gray
        createButton.isEnabled = isFormFilled
    }
    
    private func getCollectionCellSize(_ collectionView: UICollectionView) -> CGSize {
        let size: CGFloat = (collectionView.frame.width - 30) / 6
        return .init(
            width: size,
            height: size
        )
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func create() {
        guard let selectedCategory = selectedCategory else { return }

        let scheduleDays = selectedSchedule
            .compactMap { Weekdays(rawValue: $0.rawValue) }

        let selectedEmoji: String
        if let index = selectedEmojiIndex {
            selectedEmoji = emojis[index.item]
        } else {
            selectedEmoji = tracker?.emoji ?? "📈"
        }

        let selectedColor: UIColor
        if let colorIndex = selectedColorIndex {
            selectedColor = colors[colorIndex.item]
        } else {
            selectedColor = UIColor(hex: tracker?.color ?? "") ?? colors.first ?? .red
        }

        let trackerToPass = Tracker(
            id: tracker?.id ?? UUID(),
            title: trackerNameTextField.text ?? "",
            color: selectedColor.hexString(),
            emoji: selectedEmoji,
            schedule: scheduleDays,
            explicitDate: trackerType == .habit ? nil : Date(),
            category: selectedCategory,
            isPinned: tracker?.isPinned ?? false
        )

        if tracker != nil {
            delegate?.didUpdate(trackerToPass)
        } else {
            delegate?.didCreate(trackerToPass)
        }

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
        trackerType == .habit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerOptionCell else {
            fatalError("Не удалось получить TrackerOptionCell")
        }
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        let isLastCell = indexPath.row == totalRows - 1
        let isSingleCell = totalRows == 1

        if indexPath.row == 0 {
            cell.configure(
                title: .localized.localized.categoryTitle,
                value: selectedCategory?.title,
                isLastCell: isLastCell,
                isSingleCell: isSingleCell
            )
        } else {
            let selectedScheduleString = selectedSchedule.map { $0.rawValue }.joined(separator: ", ")
            
            cell.configure(title: .localized.localized.scheduleTitle, value: selectedScheduleString, isLastCell: isLastCell, isSingleCell: isSingleCell)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let viewModel = CategoryListViewModel(
                categoryStore: .init(),
                selectedCategoryId: selectedCategory?.id
            )
            let categoryListVC = CategoryListViewController(viewModel: viewModel) { [weak self] category in
                self?.selectedCategory = category
                self?.updateCreateButtonState()
            }
            categoryListVC.modalPresentationStyle = .formSheet
            present(categoryListVC, animated: true, completion: nil)
        }
        
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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let isSelected = (indexPath == selectedColorIndex)
            cell.configure(with: colors[indexPath.item], isSelected: isSelected)
            return cell
        } else if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
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

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        getCollectionCellSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
}


extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [Weekdays]) {
        selectedSchedule = schedule
        tableView.reloadData()
        updateCreateButtonState()
    }
}

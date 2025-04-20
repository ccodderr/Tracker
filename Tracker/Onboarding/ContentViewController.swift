//
//  ContentViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import UIKit

final class  ContentViewController: UIViewController {
    var pageController = UIPageControl()
    private let backgroundImage: UIImageView
    private lazy var titleTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var curentPage = 0
    
    init(backgroundImage: UIImage?, text: String, curentPage: Int) {
        self.backgroundImage = .init(image: backgroundImage)
        self.curentPage = curentPage
        super.init(nibName: nil, bundle: nil)
        
        self.titleTextLabel.text = text
        self.backgroundImage.contentMode = .scaleAspectFill

    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
        
        view.addSubview(backgroundImage)
        view.addSubview(titleTextLabel)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            titleTextLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleTextLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 70),
            titleTextLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleTextLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}

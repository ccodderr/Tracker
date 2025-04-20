//
//  LaunchScreen.swift
//  Tracker
//
//  Created by Yana Silosieva on 03.02.2025.
//

import UIKit

final class LaunchScreen: UIViewController {
    
    //    MARK: Properties
    private lazy var image = UIImageView(image: UIImage(named: "Logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let vc = PageViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        tabBarController.tabBar.backgroundColor = .white
        self.present(tabBarController, animated: true)
    }
    
    //    MARK: Methods
    private func setupView() {
        view.backgroundColor = .blue
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 91),
            image.heightAnchor.constraint(equalToConstant: 94),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

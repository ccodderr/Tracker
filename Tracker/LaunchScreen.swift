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
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            showMainInterface()
        } else {
            showOnboarding()
        }
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
    
    private func showOnboarding() {
        let onboardingVC = PageViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        
        onboardingVC.onFinish = { [weak self] in
            guard let self = self else { return }
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self.dismiss(animated: true) {
                self.showMainInterface()
            }
        }
        
        present(onboardingVC, animated: true)
    }
    
    private func showMainInterface() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

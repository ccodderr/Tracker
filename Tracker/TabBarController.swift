//
//  TabBarController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBar.backgroundColor = .ypWhite
        tabBar.barTintColor = .gray
        tabBar.tintColor = .ypBlue
        tabBar.isTranslucent = false
        
        let trackerViewController = TrackersViewController()
        trackerViewController.presenter = TrackersPresenter()
        
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: .localized.localized.trackersTitle,
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.presenter = StatisticsPresenter()
        
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: .localized.localized.statisticsTitle,
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [
            trackerNavigationController, statisticsNavigationController
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

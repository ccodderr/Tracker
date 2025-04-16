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
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .gray
        tabBar.tintColor = .ypBlue
        tabBar.isTranslucent = false
        
        let trackerViewController = TrackersViewController()
        trackerViewController.presenter = TrackersPresenter()
        
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.presenter = StatisticsPresenter()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackerNavigationController, statisticsViewController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

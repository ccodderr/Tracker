//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

import UIKit

protocol StatisticsViewControllerProtocol: AnyObject {
    var presenter: StatisticsPresenterProtocol? { get set }
}

final class StatisticsViewController: UIViewController {
    var presenter: StatisticsPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
    }
}

//
//  StatisticsPresenter.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

protocol StatisticsPresenterProtocol: AnyObject {
    var view: StatisticsViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class StatisticsPresenter: StatisticsPresenterProtocol {
    var view: (any StatisticsViewControllerProtocol)?
    
    func viewDidLoad() {
    }
    
}

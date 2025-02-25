//
//  TrackerPresenter.swift
//  Tracker
//
//  Created by Yana Silosieva on 23.02.2025.
//

protocol TrackerPresenterProtocol: AnyObject {
    var view: TrackerViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class TrackerPresenter: TrackerPresenterProtocol {
    var view: (any TrackerViewControllerProtocol)?
    
    func viewDidLoad() {
    }
}

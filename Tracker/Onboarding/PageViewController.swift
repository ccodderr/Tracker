//
//  PageViewController.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import UIKit

struct PageContent {
    let image: String
    let title: String
}

final class PageViewController: UIPageViewController {
    var onFinish: (() -> Void)?
    
    private let contents: [PageContent] = [
        .init(image: "onboardingImage.1", title: .localized.localized.onboardingTitle1),
        .init(image: "onboardingImage.2", title: .localized.localized.onboardingTitle2)
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = contents.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let btn = UIButton()
        btn.setTitle(.localized.localized.onboardingButtonTitle, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .ypBlack
        btn.layer.cornerRadius = 16
        btn.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
        return btn
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setViewControllers(
            [
                ContentViewController(
                    backgroundImage: UIImage(named: contents[.zero].image),
                    text: contents[.zero].title,
                    currentPage: .zero
                )
            ],
            direction: .forward,
            animated: true,
            completion: nil
        )
        
        view.addSubview(pageControl)
        view.addSubview(button)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -69),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: button.safeAreaLayoutGuide.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func buttonTapped() {
        onFinish?()
        
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        self.present(tabBar, animated: true)
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ContentViewController else { return nil }
        
        let previousIndex = vc.currentPage - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return ContentViewController(
            backgroundImage: UIImage(named: contents[previousIndex].image),
            text: contents[previousIndex].title,
            currentPage: previousIndex
        )
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ContentViewController else { return nil }
        
        let nextIndex = vc.currentPage + 1
        
        guard nextIndex < contents.count else {
            return nil
        }
        
        return ContentViewController(
            backgroundImage: UIImage(named: contents[nextIndex].image),
            text: contents[nextIndex].title,
            currentPage: nextIndex
        )
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? ContentViewController
        else { return }
        
        pageControl.currentPage = currentVC.currentPage
    }
}

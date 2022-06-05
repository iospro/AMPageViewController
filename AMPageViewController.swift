//
//  AMPageViewController.swift
//
//  Created by Alexey Matveev on 31.01.18.
//
//  The MIT License (MIT)
//
//  Copyright © 2018 Alexey Matveev. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit

/// UIPageViewController subclass with very simple interface.
/// It allows use cycled navigation without any well-known exceptions and handle UITableView cell swipes.
class AMPageViewController: UIPageViewController {
    
    private struct Const {
        /// when allowsTableCellSwipes = true it sets boundary insets to observe cell swipes
        static let swipeThreshold = 40.0
    }

    /// Turn on/off PageControl at the bottom
    @objc var showPageControl: Bool = true
    
    /// Enable cycle scroll
    @objc var looping: Bool = true
        
    /// Boundary bounces on swipe without looping
    @objc var bounceEnabled: Bool = true
    
    /// Permission to handle UITableView cell swipes
    @objc var allowsTableCellSwipes: Bool = false
    
    /// Array of all viewControllers
    @objc var source: [UIViewController]? {
        
        didSet {
            let count = source?.count ?? 0
            if count > 0 {
                dataSource = count > 1 ? self : nil
            }
            else {
                dataSource = nil
                delegate = nil
            }
            
            updateBounceStrategy()
        }
    }
    
    /// Index of the current viewController from source
    @objc var pageIndex: Int {
        
        get {
            var currentPageIndex: Int = 0
            if let vc = viewControllers?.first, let source = source, let pageIndex = source.firstIndex(of: vc) {
                currentPageIndex = pageIndex
            }
            
            return currentPageIndex
        }
        
        set {
            guard newValue >= 0, let source = source, newValue < source.count else { return }
            
            let vc = source[newValue]
            let direction: UIPageViewController.NavigationDirection = newValue < pageIndex ? .reverse : .forward
            if viewControllers?.first != vc {
                setViewController(vc, direction: direction, animated: animationEnabled)
            }
            
            if !animationEnabled {
                animationEnabled = true // after first page set without animation
            }
        }
    }
    
    
    /// override delegate set for empty source
    override weak var delegate: UIPageViewControllerDelegate? {
        
        get {
            super.delegate
        }
            
        set {
            if source?.count ?? 0 > 0 {
                super.delegate = newValue
            }
            else {
                super.delegate = nil
            }
        }
    }

    private var animationEnabled: Bool = false
    
    private var queuingScrollView: UIScrollView?
    
    
    /// Initializer in scroll-mode with interPageSpacing
    @objc init(navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal, interPageSpacing: Int = 5) {
        
        let options = (interPageSpacing > 0) ? [UIPageViewController.OptionsKey.interPageSpacing : interPageSpacing] : nil
        
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBounceStrategy()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !showPageControl {
            view.subviews.forEach { sv in
                if let scrollView = sv as? UIScrollView {
                    scrollView.frame.size.height = view.frame.height
                }
            }
        }
    }
    
    /// Set ViewController by index from source
    @objc func setPageIndex(_ index: Int, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        
        guard index >= 0, let source = source, index < source.count else { return }
        
        let vc = source[index]
        let direction: UIPageViewController.NavigationDirection = index < pageIndex ? .reverse : .forward
        
        setViewController(vc, direction: direction, animated: animated, completion: completion)
    }
    

    private func setViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        
        super.setViewControllers([viewController], direction: direction, animated: animated, completion: completion)
    }
    
    private func updateBounceStrategy() {
        
        let shouldBounce = looping && source?.count ?? 0 > 2
        let forbidBounces = !shouldBounce && !bounceEnabled

        view.subviews.forEach { sv in
            if let scrollView = sv as? UIScrollView {
                                
                scrollView.delegate = forbidBounces ? self : nil
                
                if allowsTableCellSwipes {
                    queuingScrollView = scrollView
                    
                    let pan = UIPanGestureRecognizer(target: self, action: nil)
                    scrollView.addGestureRecognizer(pan)
                    pan.delegate = self
                }
            }
        }
    }
}

extension AMPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let source = source, let index = source.firstIndex(of: viewController) else { return nil }
        
        let count = source.count
        
        if !looping, (index - 1) < 0 {
            return nil
        }
        
        if count == 2, index == 0 {
            return nil
        }
        
        let prevIndex = (index - 1) < 0 ? count - 1 : index - 1
        
        let pageContentViewController = source[prevIndex]
        
        return pageContentViewController
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let source = source, let index = source.firstIndex(of: viewController) else { return nil }
        
        let count = source.count
        
        if !looping, (index + 1) >= count {
            return nil
        }
        
        if count == 2, index == 1 {
            return nil
        }
        
        let nextIndex = (index + 1) >= count ? 0 : index + 1
        
        let pageContentViewController = source[nextIndex]
        
        return pageContentViewController
    }
}

extension AMPageViewController {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        showPageControl ? (source?.count ?? 0) : 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        showPageControl ? pageIndex : 0
    }
}

extension AMPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        let currentPage = pageIndex
        let pageCount = source?.count ?? 0
        
        if currentPage == 0, scrollView.contentOffset.x + scrollView.contentInset.left < 0 {
            scrollView.contentOffset = CGPoint(x: -scrollView.contentInset.left, y: scrollView.contentOffset.y)
        }
        else if currentPage == pageCount - 1, scrollView.contentInset.right < 0, scrollView.contentOffset.x + scrollView.contentInset.right > 0 {
            scrollView.contentOffset = CGPoint(x: -scrollView.contentInset.right, y: scrollView.contentOffset.y)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let currentPage = pageIndex
        let pageCount = source?.count ?? 0
        
        if currentPage == 0, scrollView.contentOffset.x + scrollView.contentInset.left < 0 {
            targetContentOffset.pointee = CGPoint(x: -scrollView.contentInset.left, y: targetContentOffset.pointee.y)
        }
        else if currentPage == pageCount - 1, scrollView.contentInset.right < 0, scrollView.contentOffset.x + scrollView.contentInset.right > 0 {
            targetContentOffset.pointee = CGPoint(x: -scrollView.contentInset.right, y: targetContentOffset.pointee.y)
        }
    }
}

extension AMPageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let queuingScrollView = queuingScrollView, gestureRecognizer.state == .began else { return true }
        
        let isQueuingScrollView = otherGestureRecognizer.view == queuingScrollView
                
        if allowsTableCellSwipes {
            
            let isTableView = otherGestureRecognizer.view is UITableView
            
            let location = gestureRecognizer.location(in: view)

            let allowedArea = min(location.x, view.bounds.width - location.x) > Const.swipeThreshold
            let allow = (isQueuingScrollView && allowedArea) || (isTableView && !allowedArea)
                        
            return allow
        }
        else {
            return isQueuingScrollView
        }
    }
}

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
/// It allows use cycled navigation without any well-known exceptions.
@objc class AMPageViewController: UIPageViewController {

    /// Turn on/off PageControl at the bottom
    @objc var showPageControl: Bool = true
    
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
        }
    }
    
    /// Index of the current viewController from source
    @objc var pageIndex: Int {
        
        get {
            var currentPageIndex: Int = 0
            if let vc = viewControllers?.first, let source = source, let pageIndex = source.index(of: vc) {
                currentPageIndex = pageIndex
            }
            
            return currentPageIndex
        }
        
        set {
            guard newValue >= 0, let source = source, newValue < source.count else { return }
            
            let vc = source[newValue]
            let direction: UIPageViewControllerNavigationDirection = newValue < pageIndex ? .reverse : .forward
            
            setViewController(vc, direction: direction)
        }
    }
    
    
    override weak var delegate: UIPageViewControllerDelegate? {
        
        get {
            return super.delegate
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
    
    /// Initializer in scroll-mode with interPageSpacing
    @objc init(navigationOrientation: UIPageViewControllerNavigationOrientation = .horizontal, interPageSpacing: Int = 0) {
        
        let options = (interPageSpacing > 0) ? [UIPageViewControllerOptionInterPageSpacingKey : 5] : nil
        
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set viewcontroller by index from source
    @objc func setPageIndex(_ index: Int, completion: ((Bool) -> Void)? = nil) {
        
        guard index > 0, let source = source, index < source.count else { return }
        
        let vc = source[index]
        let direction: UIPageViewControllerNavigationDirection = index < pageIndex ? .reverse : .forward
        
        setViewController(vc, direction: direction, completion: completion)
    }
    

    private func setViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward, completion: ((Bool) -> Void)? = nil) {
        
        super.setViewControllers([viewController], direction: direction, animated: false, completion: completion)
    }
}

extension AMPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let source = source, let index = source.index(of: viewController) else { return nil }
        
        let count = source.count
        
        if count == 2, index == 0 {
            return nil
        }
        
        let prevIndex = (index - 1) < 0 ? count - 1 : index - 1
        
        let pageContentViewController: UIViewController = source[prevIndex]
        
        return pageContentViewController
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let source = source, let index = source.index(of: viewController) else { return nil }
        
        let count = source.count
        
        if count == 2, index == 1 {
            return nil
        }
        
        let nextIndex = (index + 1) >= count ? 0 : index + 1
        
        let pageContentViewController = source[nextIndex]
        
        return pageContentViewController
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return showPageControl ? (source?.count ?? 0) : 0
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        guard showPageControl else { return 0 }
        
        return pageIndex
    }
}

<p align="center">
<img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="Swift 4.0"/>
<img src="https://img.shields.io/badge/platform-iOS-brightgreen.svg" alt="Platform: iOS"/>
<img src="https://img.shields.io/badge/Xcode-8%2B-brightgreen.svg" alt="XCode 8+"/>
<img src="https://img.shields.io/badge/iOS-8%2B-brightgreen.svg" alt="iOS 8"/>
<img src="https://img.shields.io/badge/licence-MIT-lightgray.svg" alt="Licence MIT"/>
</a>
</p>

# AMPageViewController

Convenient subclass of UIPageViewController


### Features
- [x] Simple interface.
- [x] Cycled mode for 3+ UIViewControllers.
- [x] Smart methods excluding well-know crashes (https://stackoverflow.com/questions/42833765/assertion-failure-in-uipageviewcontroller).
- [x] Pure Swift 4.


## Usage examples

- Swift

```swift
// Create array of pages
let source: [UIViewController] = ...  
// Create `pageController` with `interPageSpacing`
let pageController = AMPageViewController(interPageSpacing: 5)
// Set source array
pageController.source = source
// Set `viewController` to show by `pageIndex` between 0 and `source.count`
pageController.pageIndex = 0
// Then set `delegate` to observe navigation
pageController.delegate = ...
```

- Objective-C

```objective-c
// Create array of pages
NSArray<UIViewController *> *source = ...;
AMPageViewController *pageController = [[AMPageViewController alloc] initWithNavigationOrientation:UIPageViewControllerNavigationOrientationHorizontal interPageSpacing:5];
pageController.source = source;
pageController.pageIndex = 0;
pageController.delegate = ...;
```


## Installing

#### Manually

Download and drop `AMPageViewController.swift` file in your project.

## Requirements

* Swift 4
* iOS 8 or higher

## Authors

* **Alexey Matveev** -  [malex](https://github.com/iospro)

## Communication

* If you **found a bug**, open an issue.
* If you **have a feature request**, open an issue.
* If you **want to contribute**, submit a pull request.

## License

This project is licensed under the MIT License.
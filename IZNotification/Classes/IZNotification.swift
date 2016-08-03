//
//  IZNotification.swift
//  Pods
//
//  Created by Taylor Allred on 8/2/16.
//
//

import UIKit

public struct IZNotificationCustomizations {
    public init() {}
    
    // MARK: Behavior
    public var hideNotificationOnTap = true
    public var hideNotificationOnSwipeUp = true
    public var createUILocalNotificationIfInBackground = true
    
    // MARK: Background
    public var backgroundColor = UIColor.clearColor()
    public var blurStyle = UIBlurEffectStyle.Light
    
    // MARK: Separator
    public var separatorColor = UIColor(white: 0.5, alpha: 0.5)
    public var separatorThickness: CGFloat = 0.5
    
    // MARK: Title/Subtitle
    public var titleFont = UIFont.systemFontOfSize(20)
    public var titleColor = UIColor.blackColor()
    public var titleXInset: CGFloat = 15
    public var titleRightInset: CGFloat = 15
    public var titleYInset: CGFloat = 12
    public var titleBottomInset: CGFloat = 15
    public var subtitleFont = UIFont.systemFontOfSize(15)
    public var subtitleColor = UIColor(white: 0.15, alpha: 1)
    public var subtitleXInset: CGFloat = 15
    public var subtitleRightInset: CGFloat = 15
    public var subtitleYInset: CGFloat = 12
    public var subtitleBottomInset: CGFloat = 15
    public var titleAndSubtitleSpacing: CGFloat = 3
    public var numberOfLinesInTitle = 1
    public var numberOfLinesInSubtitle = 2
    
    // MARK: Close Button
    public var closeButtonHidden = false
    public var closeButtonWidth: CGFloat = 44
    //TODO: Draw closeButtonText natively, don't use font or assets
    public var closeButtonText = "╳"
    public var closeButtonFont = UIFont.systemFontOfSize(20)
    public var closeButtonColor = UIColor.blackColor()
}

public class IZNotificationView: UIView {
    public var title: String?
    public var subtitle: String?
    public var onTap: (() -> Void)?
    public var duration: NSTimeInterval
    
    public var customizations: IZNotificationCustomizations!
    public var animating = false
    public var backgroundView: UIVisualEffectView!
    public var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    public var subtitleLabel = UILabel()
    public var closeButton = UIButton()
    public var separator = UIView()
    
    public init(title: String?, subtitle: String?, duration: NSTimeInterval, customizations: IZNotificationCustomizations, onTap: (() -> Void)?) {
        self.duration = duration
        super.init(frame: CGRectZero)
        self.customizations = customizations
        
        self.title = title
        self.subtitle = subtitle
        self.onTap = onTap
        
        let blurView = UIBlurEffect(style: customizations.blurStyle)
        backgroundView = UIVisualEffectView(effect: blurView)
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurView))
        vibrancyView.frame = backgroundView.bounds
        vibrancyView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        backgroundView.contentView.addSubview(vibrancyView)
        backgroundView.backgroundColor = customizations.backgroundColor
        
        separator.backgroundColor = customizations.separatorColor
        backgroundView.contentView.addSubview(separator)
        
        if let title = title where !title.isEmpty {
            titleLabel.text = title
            titleLabel.font = customizations.titleFont
            titleLabel.textColor = customizations.titleColor
            backgroundView.contentView.addSubview(titleLabel)
        }
        
        if let subtitle = subtitle where !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.font = customizations.subtitleFont
            subtitleLabel.textColor = customizations.subtitleColor
            backgroundView.contentView.addSubview(titleLabel)
        }
        
        if !customizations.closeButtonHidden {
            closeButton.setTitle(customizations.closeButtonText, forState: [])
            closeButton.titleLabel!.font = customizations.closeButtonFont
            closeButton.setTitleColor(customizations.closeButtonColor, forState: [])
            closeButton.addTarget(self, action: #selector(closeButtonTapped), forControlEvents: .TouchUpInside)
            backgroundView.contentView.addSubview(closeButton)
        }
        addSubview(backgroundView)
        
        if customizations.hideNotificationOnTap {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            backgroundView.contentView.addGestureRecognizer(tap)
        }
        
        if customizations.hideNotificationOnSwipeUp {
            let swipeAwayGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeButtonTapped))
            swipeAwayGesture.direction = .Up
            backgroundView.contentView.addGestureRecognizer(swipeAwayGesture)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tapped() {
        if customizations.hideNotificationOnTap {
            IZNotification.singleton.hideNotificationView(self)
        }
        onTap?()
    }
    
    public func closeButtonTapped() {
        IZNotification.singleton.hideNotificationView(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let availableLabelWidth = frame.width - (customizations.closeButtonHidden ? 0 : customizations.closeButtonWidth)
        let availableTitleWidth = availableLabelWidth - customizations.titleXInset - customizations.titleRightInset
        let availableSubtitleWidth = availableLabelWidth - customizations.subtitleXInset - customizations.subtitleRightInset
        var bottom = CGFloat(0)
        
        if title != nil {
            titleLabel.numberOfLines = customizations.numberOfLinesInTitle
            titleLabel.frame.size.width = availableTitleWidth
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: customizations.titleXInset, y: customizations.titleYInset, width: availableTitleWidth, height: titleLabel.frame.height)
            bottom = CGRectGetMaxY(titleLabel.frame) + customizations.titleBottomInset
            
        }
        
        if subtitle != nil {
            var y = customizations.subtitleYInset
            if title != nil {
                y = CGRectGetMaxY(titleLabel.frame) + customizations.titleAndSubtitleSpacing
            }
            subtitleLabel.numberOfLines = customizations.numberOfLinesInSubtitle
            subtitleLabel.frame.size.width = availableSubtitleWidth
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(x: customizations.subtitleXInset, y: y, width: availableSubtitleWidth, height: subtitleLabel.frame.height)
            bottom = CGRectGetMaxY(subtitleLabel.frame) + customizations.subtitleBottomInset
        }
        
        if !customizations.closeButtonHidden {
            closeButton.frame = CGRect(x: frame.width - customizations.closeButtonWidth, y: 0, width: customizations.closeButtonWidth, height: bottom)
        }
        
        frame = CGRect(x: 0, y: 0, width: frame.width, height: bottom)
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: bottom)
        separator.frame = CGRect(x: 0, y: backgroundView.frame.height - customizations.separatorThickness, width: backgroundView.frame.width, height: customizations.separatorThickness)
    }
}

public class IZNotificationViewController: UIViewController {
    var forceStatusBarHidden: Bool?
    
    // Resize the notification when rotating.
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (_) -> Void in
            for subview in self.view.subviews {
                if subview is IZNotificationView {
                    subview.frame.size.width = size.width
                }
            }
            
            // Assumes that iPhone apps will hide status bar in landscape and show it in portrait.
            // Could very well be a wrong assumption, but code only executes when rotating the device
            // *while* the notification is visible, which should reduce risk of guessing wrong.
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                self.forceStatusBarHidden = size.width > size.height
                self.setNeedsStatusBarAppearanceUpdate()
            } else {
                self.forceStatusBarHidden = nil
            }
            }, completion: { _ in
        })
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return IZNotification.singleton.statusBarStyle
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return forceStatusBarHidden ?? IZNotification.singleton.statusBarHidden
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let visible = getVisibleViewController() {
            return (visible.navigationController ?? visible.tabBarController ?? visible).supportedInterfaceOrientations()
        } else {
            return UI_USER_INTERFACE_IDIOM() == .Phone ? .Portrait : .Landscape
        }
    }
    
    // As far as I'm know, this is the only proper way to get the supported interface orientation of
    // the window beneath
    public func getVisibleViewController() -> UIViewController? {
        var window: UIWindow?
        for w in UIApplication.sharedApplication().windows {
            if w.screen == UIScreen.mainScreen() && w.windowLevel == UIWindowLevelNormal && !w.hidden && w.alpha > 0 {
                window = w
                break
            }
        }
        
        if let root = window?.rootViewController {
            return getVisibleViewController(root)
        } else {
            return nil
        }
    }
    
    // This code was adapted from http://stackoverflow.com/a/20515681/2406857
    public func getVisibleViewController(from: UIViewController) -> UIViewController {
        if let nav = from as? UINavigationController, visible = nav.visibleViewController {
            return getVisibleViewController(visible)
        } else if let tabbar = from as? UITabBarController, selected = tabbar.selectedViewController {
            return getVisibleViewController(selected)
        } else if let presented = from.presentedViewController {
            return getVisibleViewController(presented)
        } else {
            for view in from.view.subviews {
                if let nextResponder = view.nextResponder() as? UIViewController {
                    return getVisibleViewController(nextResponder)
                }
            }
            return from
        }
    }
}

public class IZNotificationWindow: UIWindow {
    // Purpose of overriding is to allow tapping through this UIWindow.
    // We don't want to prevent the user from using the app while the notification is
    // visible.
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitTestResult = super.hitTest(point, withEvent: event)
        if var view: UIView? = hitTestResult {
            while view != nil {
                if view is IZNotificationView {
                    return hitTestResult
                }
                view = view!.superview
            }
        }
        return nil
    }
}

public class IZNotification: NSObject {
    public var notificationQueue = [IZNotificationView]()
    public lazy var window: UIWindow = {
        let window = IZNotificationWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = IZNotificationViewController()
        window.windowLevel = UIWindowLevelStatusBar
        return window
    }()
    public var durationTimer: NSTimer?
    public let animationDuration = NSTimeInterval(0.3)
    public var defaultCustomizations = IZNotificationCustomizations()
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask? // Defaults to guessing by traversing view controller heirarchy
    public var statusBarStyle: UIStatusBarStyle!
    public var statusBarHidden: Bool!
    public let app = UIApplication.sharedApplication()
    public static let singleton = IZNotification()
    
    public class func show(title: String?, subtitle: String?, duration: NSTimeInterval = 5, customizations: IZNotificationCustomizations = singleton.defaultCustomizations, onTap: (() -> Void)? = nil) {
        if (title ?? "").characters.count + (subtitle ?? "").characters.count == 0 {
            return // Nothing to show
        }
        
        let view = IZNotificationView(title: title, subtitle: subtitle, duration: duration, customizations: customizations, onTap: onTap)
        singleton.notificationQueue.append(view)
        if singleton.notificationQueue.count == 1 {
            singleton.showNextNotification()
        }
    }
    
    public class func hideCurrentNotification() {
        if let first = singleton.notificationQueue.first {
            singleton.hideNotificationView(first)
        }
    }
    
    public func clearNotificationQueue() {
        notificationQueue.removeAll()
    }
    
    public func showNextNotification() {
        // At this point, the dismissal animation is already completed
        
        if notificationQueue.isEmpty {
            animateIn({
                self.window.hidden = true
                }, finished: {})
        } else {
            window.hidden = true
            updateStatusBarInfo()
            window.rootViewController = IZNotificationViewController() // Too hard to update status bar appearance--just create a new one
            window.hidden = false
            let notification = notificationQueue.first!
            window.rootViewController!.view.addSubview(notification)
            showNotificationView(notification)
        }
    }
    
    // It's easier to check what the style is before we show our window than after
    public func updateStatusBarInfo() {
        self.statusBarStyle = self.app.statusBarStyle
        self.statusBarHidden = self.app.statusBarHidden
    }
    
    public func animateIn(animations: () -> Void, finished: () -> Void) {
        UIView.animateWithDuration(animationDuration, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState, .AllowAnimatedContent], animations: animations) { _ in
            finished()
        }
    }
    
    public func animateOut(animations: () -> Void, finished: () -> Void) {
        UIView.animateWithDuration(animationDuration, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState, .AllowAnimatedContent], animations: animations) { _ in
            finished()
        }
    }
    
    public func showNotificationView(notification: IZNotificationView) {
        notification.animating = true
        notification.frame.size.width = window.rootViewController!.view.frame.width
        notification.layoutIfNeeded()
        notification.frame.origin.y = -notification.frame.height
        animateIn({
            notification.frame.origin.y = 0
            }, finished: {
                notification.animating = false
                self.durationTimer?.invalidate()
                self.durationTimer = NSTimer.scheduledTimerWithTimeInterval(notification.duration, target: self, selector: #selector(self.hideNotification), userInfo: notification, repeats: false)
        })
    }
    
    public func hideNotification(timer: NSTimer) {
        hideNotificationView(timer.userInfo as! IZNotificationView)
    }
    
    public func hideNotificationView(view: IZNotificationView) {
        durationTimer?.invalidate()
        view.animating = true
        animateOut({
            view.frame.origin.y = -view.frame.height
            view.alpha = 0
            }, finished: {
                view.animating = false
                view.removeFromSuperview()
                self.notificationQueue.removeFirst()
                self.showNextNotification()
        })
    }
    
    // MARK: Handle UILocalNotifications
    public static var localNotificationSoundName = UILocalNotificationDefaultSoundName
    public static var unifiedDelegate: IZNotificationUnifiedDelegate!
    public static let unifiedIZNotificationID = "64a9c192-62e6-48fc-8fae-a6af68f77015"
    
    // Displays the IZNotification or UILocalNotification, dpending on applicationState.
    public static func showUnified(title: String? = nil, subtitle: String? = nil, action: String? = nil, data: [String: AnyObject], duration: NSTimeInterval = 5, customizations: IZNotificationCustomizations? = nil) {
        assert (unifiedDelegate != nil, "You should set the unifiedDelegate before showing a unified notification")
        
        if title == nil && subtitle == nil {
            print("IzeniAlert Error: Title and subtitle cannot be nil; that doesn't make sense")
            return
        }
        
        let app = UIApplication.sharedApplication()
        
        if app.applicationState == .Background {
            let notification = UILocalNotification()
            notification.userInfo = [
                "unified_id": IZNotification.unifiedIZNotificationID,
                "data": data
            ]
            if #available(iOS 8.2, *) {
                notification.alertTitle = title
            }
            notification.alertBody = subtitle
            notification.alertAction = action
            notification.soundName = localNotificationSoundName
            app.presentLocalNotificationNow(notification)
        } else {
            IZNotification.show(title, subtitle: subtitle, duration: duration, customizations: customizations ?? singleton.defaultCustomizations, onTap: { () -> Void in
                IZNotification.unifiedDelegate.notificationHandled(data)
            })
        }
    }
    
    public class func didReceiveLocalNotification(notification: UILocalNotification) {
        if let userInfo = notification.userInfo where userInfo["unified_id"] as? String == unifiedIZNotificationID {
            IZNotification.unifiedDelegate.notificationHandled(notification.userInfo!["data"] as! [String: AnyObject])
        }
    }
}

public protocol IZNotificationUnifiedDelegate: class {
    /**
     - parameter data:: The data passed into the IzeniAlert Object
     - parameter actionIdentifier:: the identifier of the action tapped
     */
    func notificationHandled(data: [String: AnyObject])
}
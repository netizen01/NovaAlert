//
//  NovaAlert.swift
//

import UIKit
import Cartography
import NovaCore

public class NovaAlert {
    
    // Settings elements are typically common to all Alerts within an App
    public struct Theme {
        
        public struct ActionTheme {
            public var color: UIColor? = nil
            public var highlightColor: UIColor? = UIColor(white: 0.5, alpha: 0.5)
            public var textColor: UIColor? = nil
            public var font: UIFont = .systemFontOfSize(15)
        }
        
        public var alertBackgroundColor: UIColor? = nil
        public var alertCornerRadius: CGFloat = 13
        public var alertWidth: CGFloat = 270
        public var alertTextPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        public var textSpacing: CGFloat = 12
        
        public var titleFont: UIFont = .boldSystemFontOfSize(17)
        public var messageFont: UIFont = .systemFontOfSize(13)
        
        public var titleColor: UIColor = .blackColor()
        public var messageColor: UIColor = .blackColor()
        
        public var dimmerColor: UIColor = UIColor(white: 0, alpha: 0.7)
        public var blurEffectAlpha: CGFloat = 0
        public var blurEffectStyle: UIBlurEffectStyle = .Dark
        
        public var animateInDuration: NSTimeInterval = 0.25
        public var animateOutDuration: NSTimeInterval = 0.25
        
        public var parallax: UIOffset = UIOffset(horizontal: 15, vertical: 15)
        
        public var actionDefault: ActionTheme = ActionTheme()
        public var actionCancel: ActionTheme = ActionTheme()
        public var actionDestructive: ActionTheme = ActionTheme()
        
        public var actionHeight: CGFloat = 45
        
        public var separatorColor: UIColor = UIColor(white: 0.5, alpha: 0.5)
        public var separatorWidth: CGFloat = 1 / UIScreen.mainScreen().scale
    }
    
    public struct Behavior {
        public var tapOutsideToClose: Bool = false
    }
    
    // Adjust the static Default Theme
    public static var DefaultTheme: Theme = Theme()
    public static var DefaultBehavior: Behavior = Behavior()
    
    public enum ActionType {
        case Default
        case Cancel
        case Destructive
    }
    
    public var theme: Theme = DefaultTheme
    public var behavior: Behavior = DefaultBehavior
    
    public struct Action {
        var title: String
        var type: ActionType
        var handler: (() -> (Void))?
    }
    
    public var title: String?
    public var message: String?
    private var actions: [Action] = []
    
    public let viewController = NovaAlertViewController()
    
    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
        
        viewController.alert = self
    }
    
    public func addAction(title: String, type: ActionType = .Default, handler: (() -> (Void))? = nil) -> NovaAlert {
        actions.append(Action(title: title, type: type, handler: handler))
        return self
    }
    
    public func show(animated: Bool = true) -> NovaAlert {
        // Mimic the current Status Bar Style for this UIWindow / View Controller
        statusBarStyle = UIApplication.sharedApplication().keyWindow?.rootViewController?.preferredStatusBarStyle() ?? .Default
        
        // Create the Alert Window if necessary
        if alertWindow == nil {
            alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            // Put the window under the Status Bar so it's no blurred out
            alertWindow?.windowLevel = UIWindowLevelStatusBar - 1
            alertWindow?.tintColor = UIApplication.sharedApplication().delegate?.window??.tintColor
            alertWindow?.rootViewController = viewController
            alertWindow?.makeKeyAndVisible()
        }
        
        return self
    }
    
    public func hide(animated: Bool = true, completion: (() -> ())? = nil) -> NovaAlert {
        viewController.hide(animated, completion: completion)
        return self
    }
    
    
    
    // Private
    private var alertWindow: UIWindow?
    private var statusBarStyle: UIStatusBarStyle = .Default
    
    private func destroy() {
        alertWindow?.hidden = true
        alertWindow?.rootViewController = nil
        alertWindow = nil
        viewController.alert = nil
    }
    
    deinit {
        print("deinit \(self.dynamicType)")
    }
}







public class NovaAlertViewController: UIViewController {

    private var alert: NovaAlert!
    
    public let dimmerView = UIView()
    public let alertView = NovaAlertView()
    
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .None
        modalTransitionStyle = .CrossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public override func loadView() {
        view = UIView(frame: CGRect.zero)
        view.addSubview(dimmerView)
        view.addSubview(alertView)
        
        tapGestureRecognizer.addTarget(self, action: #selector(NovaAlertViewController.tapGestureHandler(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private var alertViewContraints: ConstraintGroup?
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        dimmerView.backgroundColor = alert.theme.dimmerColor
        dimmerView.alpha = 0
        
        if alert.theme.blurEffectAlpha > 0 {
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: alert.theme.blurEffectStyle))
            blurEffectView.alpha = alert.theme.blurEffectAlpha
            dimmerView.addSubview(blurEffectView)
            constrain(blurEffectView, dimmerView) { blurEffectView, dimmerView in
                blurEffectView.edges == dimmerView.edges
            }
        }
        
        constrain(view, dimmerView) { view, dimmerView in
            dimmerView.edges == view.edges
        }
        
        alertViewContraints = constrain(view, alertView) { view, alertView in
            alertView.top == view.bottom
            alertView.centerX == view.centerX
        }
        constrain(alertView) { alertView in
            alertView.width == self.alert.theme.alertWidth
        }
        alertView.titleLabel.text = alert.title
        alertView.messageLabel.text = alert.message
        
        alertView.applyTheme(alert.theme)
        
        alertView.addActions(alert.actions, theme: alert.theme)
        
        for actionButton in alertView.actionButtons {
            actionButton.addTarget(self, action: #selector(NovaAlertViewController.actionButtonHandler(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        constrain(view, alertView, replace: alertViewContraints!) { view, alertView in
            alertView.center == view.center
        }
        UIView.animateWithDuration(alert.theme.animateInDuration) {
            self.dimmerView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    func hide(animated: Bool = true, completion: (() -> ())? = nil) {
        if animated {
            UIView.animateWithDuration(alert.theme.animateOutDuration, animations: {
                self.view.alpha = 0
            }) { finished in
                self.alert.destroy()
                completion?()
            }
        } else {
            alert.destroy()
            completion?()
        }
    }
    
    
    func tapGestureHandler(gesture: UITapGestureRecognizer) {
        if alert.behavior.tapOutsideToClose && alertView.hitTest(gesture.locationInView(alertView), withEvent: nil) == nil {
            hide()
        }
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return alert.statusBarStyle ?? .Default
    }
    
    func actionButtonHandler(button: NovaAlertActionButton) {
        button.action.handler?()
        hide()
    }
    
    deinit {
        print("deinit \(self.dynamicType)")
    }
}






public class NovaAlertActionButton: UIButton {

    private var action: NovaAlert.Action
    init(action: NovaAlert.Action) {
        self.action = action
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class NovaAlertView: UIView {
    
    private let titleLabel = UILabel(frame: CGRect.zero)
    private let messageLabel = UILabel(frame: CGRect.zero)
    private let separator = UIView(frame: CGRect.zero)
    private let actionsContainer = UIView(frame: CGRect.zero)
    private let actionsSeparator = UIView(frame: CGRect.zero)
    private lazy var backgroundView = { UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.masksToBounds = true
        
        addSubview(separator)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionsContainer)
        
        titleLabel.textAlignment = .Center
        messageLabel.textAlignment = .Center
        
        messageLabel.numberOfLines = 0
    }
    
    internal func applyTheme(theme: NovaAlert.Theme) {
        
        backgroundColor = theme.alertBackgroundColor
        if backgroundColor == nil {
            insertSubview(backgroundView, atIndex: 0)
            
            constrain(backgroundView) { backgroundView in
                backgroundView.edges == backgroundView.superview!.edges
            }
        }
        
        layer.cornerRadius = theme.alertCornerRadius
        
        titleLabel.font = theme.titleFont
        messageLabel.font = theme.messageFont
        
        titleLabel.textColor = theme.titleColor
        messageLabel.textColor = theme.messageColor
        
        separator.backgroundColor = theme.separatorColor
        actionsSeparator.backgroundColor = theme.separatorColor
        
        do {
            let parallax = theme.parallax
            let group = UIMotionEffectGroup()
            let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
            horizontal.minimumRelativeValue = -parallax.horizontal
            horizontal.maximumRelativeValue = parallax.horizontal
            let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
            vertical.minimumRelativeValue = -parallax.vertical
            vertical.maximumRelativeValue = parallax.vertical
            group.motionEffects = [horizontal, vertical]
            addMotionEffect(group)
        }
        
        constrain(titleLabel, messageLabel, separator, actionsContainer, self) { titleLabel, messageLabel, separator, actionsContainer, view in
            titleLabel.top == view.top + theme.alertTextPadding.top
            titleLabel.bottom == messageLabel.top - theme.textSpacing
            messageLabel.bottom == separator.top - theme.alertTextPadding.bottom
            separator.bottom == actionsContainer.top
            
            titleLabel.left == view.left + theme.alertTextPadding.left
            titleLabel.right == view.right - theme.alertTextPadding.right
            
            messageLabel.left == view.left + theme.alertTextPadding.left
            messageLabel.right == view.right - theme.alertTextPadding.right
            
            separator.height == theme.separatorWidth
            separator.left == view.left
            separator.right == view.right
            
            actionsContainer.left == view.left
            actionsContainer.right == view.right
            actionsContainer.bottom == view.bottom
        }
    }
    
    private var actionButtons: [UIButton] = []
    private func addActions(actions: [NovaAlert.Action], theme: NovaAlert.Theme) {
        for action in actions {
            let actionButton = NovaAlertActionButton(action: action)
            actionButton.setTitle(action.title, forState: .Normal)
            
            let actionTheme: NovaAlert.Theme.ActionTheme
            switch action.type {
            case .Default:
                actionTheme = theme.actionDefault
            case .Cancel:
                actionTheme = theme.actionCancel
            case .Destructive:
                actionTheme = theme.actionDestructive
            }
            
            actionButton.titleLabel?.font = actionTheme.font
            if let color = actionTheme.textColor {
                actionButton.setTitleColor(color, forState: .Normal)
            } else {
                actionButton.setTitleColor(tintColor, forState: .Normal)
            }
            if let color = actionTheme.color {
                actionButton.setBackgroundColor(color, forState: .Normal)
            }
            if let color = actionTheme.highlightColor {
                actionButton.setBackgroundColor(color, forState: .Highlighted)
            }
            
            actionButtons.append(actionButton)
            actionsContainer.addSubview(actionButton)
        }
        
        if actionButtons.count == 1 {
            constrain(actionsContainer, actionButtons[0]) { container, button in
                button.edges == container.edges
                button.height == theme.actionHeight
            }
        } else if actionButtons.count == 2 {
            actionsContainer.addSubview(actionsSeparator)
            constrain(actionsContainer, actionsSeparator, actionButtons[0], actionButtons[1]) { container, separator, button1, button2 in
                separator.top == container.top
                separator.bottom == container.bottom
                separator.width == theme.separatorWidth
                
                button1.left == container.left
                button1.right == separator.left
                button2.left == separator.right
                button2.right == container.right
                button1.top == container.top
                button2.top == container.top
                button1.bottom == container.bottom
                button2.bottom == container.bottom
                button1.width == button2.width
                button1.height == theme.actionHeight
                button2.height == theme.actionHeight
            }
        } else if actionButtons.count > 2 {
            
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit \(self.dynamicType)")
    }
}









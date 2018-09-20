//
//  NovaAlert.swift
//

import UIKit
import Cartography
import NovaCore

open class NovaAlert {
    
    // Settings elements are typically common to all Alerts within an App
    public struct Theme {
        
        public struct ActionTheme {
            public var color: UIColor? = nil
            public var highlightColor: UIColor? = UIColor(white: 0.5, alpha: 0.5)
            public var textColor: UIColor? = nil
            public var font: UIFont = .preferredFont(forTextStyle: UIFont.TextStyle.body)
        }
        
        public var alertBackgroundColor: UIColor? = nil
        public var alertCornerRadius: CGFloat = 13
        public var alertWidth: CGFloat = 270
        public var alertTextPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        public var textSpacing: CGFloat = 12
        
        public var titleFont: UIFont = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
        public var messageFont: UIFont = .preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        public var titleColor: UIColor = .black
        public var messageColor: UIColor = .black
        
        public var dimmerColor: UIColor = UIColor(white: 0, alpha: 0.7)
        public var blurEffectAlpha: CGFloat = 0
        public var blurEffectStyle: UIBlurEffect.Style = .dark
        
        public var animateInDuration: TimeInterval = 0.25
        public var animateOutDuration: TimeInterval = 0.25
        
        public var parallax: UIOffset = UIOffset(horizontal: 15, vertical: 15)
        
        public var actionDefault: ActionTheme = ActionTheme()
        public var actionCancel: ActionTheme = ActionTheme()
        public var actionDestructive: ActionTheme = ActionTheme()
        
        public var actionHeight: CGFloat = 45
        
        public var separatorColor: UIColor = UIColor(white: 0.5, alpha: 0.5)
        public var separatorWidth: CGFloat = 1 / UIScreen.main.scale
    }
    
    public struct Behavior {
        public var tapOutsideToClose: Bool = false
    }
    
    // Adjust the static Default Theme
    open static var DefaultTheme: Theme = Theme()
    open static var DefaultBehavior: Behavior = Behavior()
    
    public enum ActionType {
        case `default`
        case cancel
        case destructive
    }
    
    open var theme: Theme = DefaultTheme
    open var behavior: Behavior = DefaultBehavior
    
    public struct Action {
        var title: String
        var type: ActionType
        var handler: (() -> (Void))?
    }
    
    open var title: String?
    open var message: String?
    fileprivate var actions: [Action] = []
    
    open let viewController = NovaAlertViewController()
    
    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
        
        viewController.alert = self
    }
    
    @discardableResult open func addAction(_ title: String, type: ActionType = .default, handler: (() -> (Void))? = nil) -> NovaAlert {
        actions.append(Action(title: title, type: type, handler: handler))
        return self
    }
    
    @discardableResult open func show(_ animated: Bool = true) -> NovaAlert {
        // Mimic the current Status Bar Style for this UIWindow / View Controller
        statusBarStyle = UIApplication.shared.keyWindow?.rootViewController?.preferredStatusBarStyle ?? .default
        
        // Create the Alert Window if necessary
        if alertWindow == nil {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
            // Put the window under the Status Bar so it's no blurred out
            alertWindow?.windowLevel = UIWindow.Level.statusBar - 1
            alertWindow?.tintColor = UIApplication.shared.delegate?.window??.tintColor
            alertWindow?.rootViewController = viewController
            alertWindow?.makeKeyAndVisible()
        }
        
        return self
    }
    
    @discardableResult open func hide(_ animated: Bool = true, completion: (() -> ())? = nil) -> NovaAlert {
        viewController.hide(animated, completion: completion)
        return self
    }
    
    
    
    // Private
    fileprivate var alertWindow: UIWindow?
    fileprivate var statusBarStyle: UIStatusBarStyle = .default
    
    fileprivate func destroy() {
        alertWindow?.isHidden = true
        alertWindow?.rootViewController = nil
        alertWindow = nil
        viewController.alert = nil
    }
    
}







open class NovaAlertViewController: UIViewController {

    fileprivate var alert: NovaAlert!
    
    open let dimmerView = UIView()
    open let alertView = NovaAlertView()
    
    fileprivate let tapGestureRecognizer = UITapGestureRecognizer()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .none
        modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    open override func loadView() {
        view = UIView(frame: CGRect.zero)
        view.addSubview(dimmerView)
        view.addSubview(alertView)
        
        tapGestureRecognizer.addTarget(self, action: #selector(NovaAlertViewController.tapGestureHandler(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate var alertViewContraints: ConstraintGroup?
    open override func viewDidLoad() {
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
            actionButton.addTarget(self, action: #selector(NovaAlertViewController.actionButtonHandler(_:)), for: .touchUpInside)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        constrain(view, alertView, replace: alertViewContraints!) { view, alertView in
            alertView.center == view.center
        }
        UIView.animate(withDuration: alert.theme.animateInDuration, animations: {
            self.dimmerView.alpha = 1
            self.view.layoutIfNeeded()
        }) 
    }

    func hide(_ animated: Bool = true, completion: (() -> ())? = nil) {
        if animated {
            UIView.animate(withDuration: alert.theme.animateOutDuration, animations: {
                self.view.alpha = 0
            }, completion: { finished in
                self.alert.destroy()
                completion?()
            }) 
        } else {
            alert.destroy()
            completion?()
        }
    }
    
    
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if alert.behavior.tapOutsideToClose && alertView.hitTest(gesture.location(in: alertView), with: nil) == nil {
            hide()
        }
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return alert.statusBarStyle
    }
    
    @objc func actionButtonHandler(_ button: NovaAlertActionButton) {
        button.action.handler?()
        hide()
    }
    
}






open class NovaAlertActionButton: UIButton {

    fileprivate var action: NovaAlert.Action
    init(action: NovaAlert.Action) {
        self.action = action
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

open class NovaAlertView: UIView {
    
    fileprivate let titleLabel = UILabel(frame: CGRect.zero)
    fileprivate let messageLabel = UILabel(frame: CGRect.zero)
    fileprivate let separator = UIView(frame: CGRect.zero)
    fileprivate let actionsContainer = UIView(frame: CGRect.zero)
    fileprivate let actionsSeparator = UIView(frame: CGRect.zero)
    fileprivate lazy var backgroundView = { UIVisualEffectView(effect: UIBlurEffect(style: .extraLight)) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.masksToBounds = true
        
        addSubview(separator)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionsContainer)
        
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        messageLabel.numberOfLines = 0
    }
    
    internal func applyTheme(_ theme: NovaAlert.Theme) {
        
        backgroundColor = theme.alertBackgroundColor
        if backgroundColor == nil {
            insertSubview(backgroundView, at: 0)
            
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
            let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            horizontal.minimumRelativeValue = -parallax.horizontal
            horizontal.maximumRelativeValue = parallax.horizontal
            let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
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
    
    fileprivate var actionButtons: [UIButton] = []
    fileprivate func addActions(_ actions: [NovaAlert.Action], theme: NovaAlert.Theme) {
        for action in actions {
            let actionButton = NovaAlertActionButton(action: action)
            actionButton.setTitle(action.title, for: .normal)
            
            let actionTheme: NovaAlert.Theme.ActionTheme
            switch action.type {
            case .default:
                actionTheme = theme.actionDefault
            case .cancel:
                actionTheme = theme.actionCancel
            case .destructive:
                actionTheme = theme.actionDestructive
            }
            
            actionButton.titleLabel?.font = actionTheme.font
            if let color = actionTheme.textColor {
                actionButton.setTitleColor(color, for: .normal)
            } else {
                actionButton.setTitleColor(tintColor, for: .normal)
            }
            if let color = actionTheme.color {
                actionButton.setBackgroundColor(color, forState: .normal)
            }
            if let color = actionTheme.highlightColor {
                actionButton.setBackgroundColor(color, forState: .highlighted)
            }
            actionButton.titleLabel?.lineBreakMode = .byWordWrapping
            
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
    
}


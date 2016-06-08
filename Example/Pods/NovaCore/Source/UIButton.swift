//
//  UIButton.swift
//  NovaCore
//

import UIKit

extension UIButton {
    
    public func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        setBackgroundImage(color.pixel(), forState: state)
    }
    
}

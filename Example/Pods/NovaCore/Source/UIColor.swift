//
//  UIColor.swift
//  NovaCore
//

import UIKit

extension UIColor {
    
    public func pixel() -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, CGColor)
        CGContextFillRect(ctx, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func resizableImage(cornerRadius: CGFloat) -> UIImage {
        let size = CGSize(width: cornerRadius * 2 + 1, height: cornerRadius * 2 + 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        setFill()
        let path =  UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: size), cornerRadius: cornerRadius)
        path.fill()
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        image = image.resizableImageWithCapInsets(UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius), resizingMode: .Stretch)
        return image
    }
    
    public func lighter(amount : CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    public func darker(amount : CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    public func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * amount, alpha: alpha)
        } else {
            return self
        }
    }
}

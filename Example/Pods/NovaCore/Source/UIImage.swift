//
//  UIImage.swift
//  NovaCore
//

import UIKit

extension UIImage {   
    
    public func convertToGrayScale() -> UIImage {
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, nil, CGImageAlphaInfo.None.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
        let mask = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: CGImageCreateWithMask(convertToGrayScaleNoAlpha(), mask)!, scale: scale, orientation:imageOrientation)
    }
    
    public class func imageWithColor(color: UIColor, cornerRadius: CGFloat) -> UIImage {
        return color.resizableImage(cornerRadius)
    }
    
}




extension UIImage {
    
    private func convertToGrayScaleNoAlpha() -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.None.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage)
        return CGBitmapContextCreateImage(context)!
    }
    
}
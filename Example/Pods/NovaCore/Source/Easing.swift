//
//  Easing.swift
//  NovaCore
//

import Foundation

public class Easing {
    
    public class func sineInOut(time time: Double, start: Double, delta: Double, duration: Double) -> Double {
        return -delta / 2 * (cos(M_PI * time / duration) - 1) + start
    }
    
}
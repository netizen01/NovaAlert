//
//  NovaApp.swift
//  NovaCore
//

import Foundation

@objc public class UIApplicationVersion: NSObject {
    
    public var majorVersion: Int = 0
    public var minorVersion: Int = 0
    public var patchVersion: Int = 0
    public var buildNumber: Int = 0

    public func toString(major: Bool = true, minor: Bool = true, patch: Bool = true, build: Bool = false) -> String {
        var v: [String] = []
        if major {
            v.append("\(majorVersion)")
        }
        if minor {
            v.append("\(minorVersion)")
        }
        if patch {
            v.append("\(patchVersion)")
        }
        var version = v.joinWithSeparator(".")
        if build {
            version += " (\(buildNumber))"
        }
        return version
    }

    override public var description: String {
        return toString()
    }

}

@objc public class NovaApp: NSObject {

    public class func bundleIdentifier() -> String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
    }

    public class func applicationVersion() -> UIApplicationVersion {
        let av = UIApplicationVersion()

        if let infoDict = NSBundle.mainBundle().infoDictionary {
            if let versionString = infoDict["CFBundleShortVersionString"] as? String {
                let versions = versionString.componentsSeparatedByString(".")
                if versions.count > 0, let vInt = Int(versions[0]) {
                    av.majorVersion = vInt
                }
                if versions.count > 1, let vInt = Int(versions[1]) {
                    av.minorVersion = vInt
                }
                if versions.count > 2, let vInt = Int(versions[2]) {
                    av.patchVersion = vInt
                }
            }
            if let buildNumber = infoDict[kCFBundleVersionKey as String] as? NSString {
                av.buildNumber = buildNumber.integerValue;
            }
        }

        return av
    }
    
}

//
//  VSLogCaughter.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/11.
//

import Foundation
import UIKit

@objc open class SFAppRealTimeLogCaughter: NSObject {
    static let shared = SFAppRealTimeLogCaughter()
    private var showLogWindow: CaughterWindow?
    
    private override init() {
    }
    
    @objc open class func enable() {
        DispatchQueue.main.async {
            if self.shared.showLogWindow == nil {
                if #available(iOS 13.0, *) {
                    for windowScene: UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                        if windowScene.activationState == .foregroundActive || windowScene.activationState == .foregroundInactive {
                            self.shared.showLogWindow = CaughterWindow(windowScene: windowScene)
                        }
                    }
                } else {
                    self.shared.showLogWindow = CaughterWindow(frame: UIScreen.main.bounds)
                }
            }
            self.shared.showLogWindow?.show()
            print("【日志抓取工具已开启】")
        }
    }
}

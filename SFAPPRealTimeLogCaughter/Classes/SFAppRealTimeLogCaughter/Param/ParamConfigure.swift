//
//  ParamConfigure.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/9.
//

import Foundation
import UIKit

let isIPhoneX = SFMethod.isIPhoneX()
let SafeAreaBottomH: CGFloat = isIPhoneX ? iPhoneXBottomH : 0
let iPhoneXBottomH: CGFloat = 34.0
let SafeAreaTopH: CGFloat = isIPhoneX ? 44.0 : 20.0
let MaxDisplayNumberInTextView: Int = 100
let MaxStorageInModel: Int = 2000

struct sizeOfFloatBtn {
    let x: CGFloat = 40.0
    let y: CGFloat = 40.0
    let corner: CGFloat = 20.0
    let edgeWidth: CGFloat = 10.0
}

struct SFMethod {
    public static func isIPhoneX() -> Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        if #available(iOS 11.0, *) {
            if UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20.0 > CGFloat(20.0) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

struct MyColor {
    let backgroundColor: UIColor = UIColor(red: 0, green: 14/255, blue: 30/255, alpha: 0.6)
    let light: UIColor = UIColor(red: 0, green: 193/255, blue: 188/255, alpha: 1)
    let linegray: UIColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    let buttongray: UIColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
    let searchgray: UIColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
}

//
//  UpdateDataDelegate.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/19.
//

import Foundation

protocol ReceiveDataDelegate {
    func updateData()
}

protocol SearchDelegate {
    func search(_: String)
}

protocol ClearDelegate {
    func cleanSearchBarText()
}

//
//  VSLogCaughterLogModel.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/12.
//

import Foundation
class LogDataModel {
    private var queue = DispatchQueue(label: "SafeArrayModel", attributes: .concurrent)
    private var logData: [String] = [] {
        didSet {
            queue.async(flags: .barrier) {
                if self.logData.count > MaxStorageInModel {
                    self.logData = self.logData.suffix(MaxStorageInModel)
                }
            }
        }
    }
    public var length: Int {
        get {
            queue.sync {
                var count: Int = 0
                for item in self.logData {
                    count += item.count
                }
                return count
            }
        }
    }
    private var count: Int {
        get {
            queue.sync {
                return self.logData.count
            }
        }
    }

    init() {
        logData = []
    }
    
    public func setLog(data: String) {
        queue.async(flags: .barrier) {
            self.logData.append(data)
        }
    }
    
    public func getLog() -> [String] {
        queue.sync {
            return self.logData
        }
    }
    
    public func getLogAsString() -> String {
        queue.sync {
            var data: String = ""
            for item in self.logData {
                data += item
            }
            return data
        }
    }
    
    public func clear() {
        queue.async(flags: .barrier) {
            self.logData.removeAll()
        }
    }
}

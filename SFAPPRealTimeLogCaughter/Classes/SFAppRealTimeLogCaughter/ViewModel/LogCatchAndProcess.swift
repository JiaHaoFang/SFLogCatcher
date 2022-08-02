//
//  LogCatchAndProcess.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/11.
//

import Foundation

class LogCatchAndProcess {
    //MARK: - Private data
    private var rawLogData = LogDataModel()
    private var matchedLogData = LogDataModel()
    var receiveDelegate: ReceiveDataDelegate?
    var cleanDelegate: ClearDelegate?
    
    private var pipe = Pipe()
    private var rootFolderPath: String {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return "" }
        let logPath = path + "/Log/"
        return logPath
    }
    private var filePathStr: [String] = []
    public var matchStr: String = ""
    public var onOffState: Bool = false
    
    private var originalERR: Int32 = dup(STDERR_FILENO)
    private var originalOUT: Int32 = dup(STDOUT_FILENO)
    
    private var timer: Timer?
    
    //MARK: - Init
    init() {
        redirect()
        registTimer()
    }

    deinit {
        pipe.fileHandleForReading.readabilityHandler = nil
//        self.removeAllFile()
    }
}

//MARK: - IO
extension LogCatchAndProcess {
    public func getLog(_ isSearching: Bool) -> [String] {
        return (isSearching ? matchedLogData.getLog().suffix(MaxDisplayNumberInTextView).reversed() : rawLogData.getLog().suffix(MaxDisplayNumberInTextView).reversed())
    }
}

extension LogCatchAndProcess {
    public func switchState() -> Bool {
        defer {
            self.redirect()
        }
        self.onOffState = !self.onOffState
        return onOffState
    }
}

//MARK: - Catch
extension LogCatchAndProcess {
    func redirect() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if self.onOffState {
                setvbuf(stderr, nil, _IONBF, 0)
                setvbuf(stdout, nil, _IONBF, 0)
                dup2(self.pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
                dup2(self.pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                self.pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    let str = String(data: data, encoding: .utf8) ?? "<Non-utf8 data of size\(data.count)>\n"
                    self.rawLogData.setLog(data: str)
                    self.dataFiltAndAppend()
                }
            } else {
                dup2(self.originalERR, STDERR_FILENO)
                dup2(self.originalOUT, STDOUT_FILENO)
            }
//            self.receiveDelegate?.updateData()
        }
    }
    
    func registTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.onOffState {
                self.receiveDelegate?.updateData()
            }
        }
        self.timer?.fire()
    }
}

//MARK: - Search
extension LogCatchAndProcess: SearchDelegate {
    func search(_ matchStr: String) {
        self.matchStr = matchStr
        dataFiltAndAppend()
    }
}
extension LogCatchAndProcess {
    private func dataFiltAndAppend() {
        self.matchedLogData.clear()
        for item in self.rawLogData.getLog() {
            if item.contains(self.matchStr) {
                self.matchedLogData.setLog(data: item)
            }
        }
    }
}

//MARK: - Clean
extension LogCatchAndProcess {
    public func cleanAllAndStartAgain() {
        cleanDelegate?.cleanSearchBarText()
        self.rawLogData.clear() //需要先清空Model
        self.matchedLogData.clear()
        redirect()
    }
}

//MARK: - Save
extension LogCatchAndProcess {
    public func saveFile() -> String {
        let saveFileFolderStr = self.rootFolderPath + date2String(Date())
        self.filePathStr.append(saveFileFolderStr)
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: URL(fileURLWithPath: saveFileFolderStr), withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        do {
            let rawLogFile = saveFileFolderStr + "/raw.txt"
            try self.rawLogData.getLogAsString().write(to: URL(fileURLWithPath: rawLogFile), atomically: true, encoding: .utf8)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        do {
            let matchedLogFile = saveFileFolderStr + "/matched.txt"
            try self.matchedLogData.getLogAsString().write(to: URL(fileURLWithPath: matchedLogFile), atomically: true, encoding: .utf8)
        } catch let error {
            NSLog("error: \n \(error)")
        }
        NSLog("\nSave successed! \nPath: \(self.filePathStr.last ?? "Save Fail")")
        return self.filePathStr.last ?? ""
    }
    
    private func date2String(_ date:Date, dateFormat: String = "yyyy-MM-dd-HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
    
    public func saveSuccess() {

    }
    
    public func fileURL() -> [URL] {
        return [URL(fileURLWithPath: self.rootFolderPath)]
    }
    
    public func removeAllFile() {
        LogCatchAndProcess.removeFolder(folderUrl: self.rootFolderPath)
    }
    
    static func removeFolder(folderUrl: String) {
        let fileManger = FileManager.default
        guard let files = fileManger.subpaths(atPath: folderUrl) as [String]? else { return }
        for file in files.reversed()
        {
            do{
                try fileManger.removeItem(atPath: folderUrl + "/\(file)")
                print("Success to remove folder: \(file)")
            }catch{
                print("Failder to remove folder...")
            }
        }
    }
}


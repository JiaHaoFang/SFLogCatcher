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
    private let fileDelegateQueue = DispatchQueue.global()
    private var source: DispatchSourceRead?
    private var filePathStr: [String] = []
    private var savedFilePathStr: [String] = []
    public var matchStr: String = ""
    public var onOffState: Bool = false
    
    private var originalERR: Int32 = dup(STDERR_FILENO)
    private var originalOUT: Int32 = dup(STDOUT_FILENO)
    
    //MARK: - Init
    init() {
        redirect()
    }

    deinit {
        pipe.fileHandleForReading.readabilityHandler = nil
//        self.removeAllFile()
    }
}

//MARK: - IO
extension LogCatchAndProcess {
    public func returnLog(_ isSearching: Bool) -> String {
        var data: String = ""
        for item in (isSearching ? matchedLogData.getLog().suffix(MaxDisplayNumberInTextView) : rawLogData.getLog().suffix(MaxDisplayNumberInTextView)) {
            data += item
        }
        return data
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
        if self.onOffState {
            setvbuf(stderr, nil, _IONBF, 0)
            setvbuf(stdout, nil, _IONBF, 0)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
            pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                let str = String(data: data, encoding: .utf8) ?? "<Non-utf8 data of size\(data.count)>\n"
                self?.rawLogData.setLog(data: str)
                self?.dataFiltAndAppend()
                self?.receiveDelegate?.updateData()
            }
        } else {
            dup2(self.originalERR, STDERR_FILENO)
            dup2(self.originalOUT, STDOUT_FILENO)
        }
        self.receiveDelegate?.updateData()
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
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let date = Date()
        let saveFileFolderStr = documentsDirectory + "/Log/" + date2String(date)
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
        self.savedFilePathStr = self.filePathStr
    }
    
    public func unsavedFileURL() -> [URL] {
        var url: [URL] = []
        var unsavedFilePathStr: [String] = []
        for item in self.filePathStr {
            if !self.savedFilePathStr.contains(item) {
                unsavedFilePathStr.append(item)
            }
        }
        for item in unsavedFilePathStr  {
            url.append(URL(fileURLWithPath: item))
        }
        return url
    }
    
    public func removeAllFile() {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let saveFileFolderStr = documentsDirectory + "/Log"
        LogCatchAndProcess.removeFolder(folderUrl: saveFileFolderStr)
    }
    
    static func removeFolder(folderUrl: String) {
        let fileManger = FileManager.default
        let filess:[AnyObject]? = fileManger.subpaths(atPath: folderUrl)! as [AnyObject]
        guard let files = filess else { return }
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


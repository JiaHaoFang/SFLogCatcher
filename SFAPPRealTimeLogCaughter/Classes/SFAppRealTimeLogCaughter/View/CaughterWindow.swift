//
//  CaughterWindow.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/10.
//

import UIKit
import SnapKit
import SVProgressHUD

private let LogItemCellName: String = "aaa"

class CaughterWindow: UIWindow {
    //MARK: - Private data
    private var caughter: LogCatchAndProcess?
    private var wakeUpBtnPosition = CGPoint(x: sizeOfFloatBtn().edgeWidth, y: 200)
    /// 记录窗口显示的状态，true为日志窗口，false为悬浮窗口
    private var windowStatus: Bool = false
    /// 记录窗口隐藏状态
    private var windowIsHidden: Bool = false
    /// rlog
    private var logAttr: [NSMutableAttributedString] = []
    
    //MARK: - Subviews
    private lazy var wakeUpView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = .clear
        return view
    }()
    private lazy var showLogView: UIView = {
        let view = UIView()
        view.frame = .zero
        view.backgroundColor = MyColor().backgroundColor
        return view
    }()
    private lazy var wakeUpBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeOfFloatBtn().x, height: sizeOfFloatBtn().y))
        btn.setTitle("Off", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = UIColor.init(red: 0, green: 193/255, blue: 188/255, alpha: 0.5)
        btn.layer.cornerRadius = sizeOfFloatBtn().corner
        btn.addTarget(self, action: #selector(floatBtnAction(sender:)), for: .touchUpInside)
        return btn
    }()
    private lazy var hideBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(hideBtnAction), for: .touchUpInside)
        btn.setTitle("Hide", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        btn.setTitle("Save", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var clearBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(clearBtnAction), for: .touchUpInside)
        btn.setTitle("Clear", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.caughter?.cleanDelegate = self.searchBar
        return btn
    }()
    private lazy var onOffBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .gray
        btn.addTarget(self, action: #selector(onOffBtnAction), for: .touchUpInside)
        btn.setTitle("State", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    private lazy var searchBar: SearchBarForWindow = {
        let sb = SearchBarForWindow()
        guard let caughter = caughter else { return sb }
        sb.searchDelegate = self.caughter
        return sb
    }()
    private lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 1
        tableview.separatorStyle = .singleLine
//        if #available(iOS 15.0, *) {
//            self.setValue(0, forKey: "sectionHeaderTopPadding")
//        }
        tableview.register(LogItemCell.classForCoder(), forCellReuseIdentifier: LogItemCellName)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(processGesture(gesture:)))
        longPress.minimumPressDuration = 0.5
        tableview.addGestureRecognizer(longPress)
        return tableview
    }()
    private lazy var alertWindowForShare: UIAlertController = {
        let alert = UIAlertController(title: "Saved successfully!", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let share = UIAlertAction(title: "Share File", style: .default, handler: { [weak self] _ in
            self?.sharing()
        })
        alert.addAction(ok)
        alert.addAction(share)
        return alert
    }()
    private lazy var alertWindowForClear: UIAlertController = {
        let clear = UIAlertController(title: "Screen is cleared", message: "", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        let clean = UIAlertAction(title: "Clean Files", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.caughter?.removeAllFile()
        })
        clear.addAction(no)
        clear.addAction(clean)
        return clear
    }()
    private lazy var alertWindowForHidden: UIAlertController = {
        let clear = UIAlertController(title: "Do you want to close the LogCatcher?", message: "", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.windowIsHidden = !self.windowIsHidden
            if self.windowStatus {
                self.showLogView.isHidden = self.windowIsHidden
            } else {
                self.wakeUpBtn.isHidden = self.windowIsHidden
            }
        })
        clear.addAction(no)
        clear.addAction(yes)
        return clear
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
}

//MARK: - IO
extension CaughterWindow {
    public func show() {
        self.isHidden = false
    }
}

//MARK: - UpdateData Delegate
extension CaughterWindow: ReceiveDataDelegate {
    func updateData() {
        guard let caughter = self.caughter else { return }
        DispatchQueue.main.async {
            self.logAttr = caughter.getLog(self.searchBar.isActive).map({ item in
                return self.setKeywordWithColor(keyword: caughter.matchStr, text: item)!
            })
            self.tableView.reloadData()
        }
    }
    
    private func setKeywordWithColor(keyword: String, text: String) -> NSMutableAttributedString? {
        let attrStr = NSMutableAttributedString(string: text)
        text.enumerateRangeOfString(searchStr: keyword) { (searchRange) in
            attrStr.addAttribute(.backgroundColor, value: UIColor.green, range: searchRange)
        }
        return attrStr
    }
}

extension String {
    fileprivate func enumerateRangeOfString(searchStr: String, block: ((_ searchRange :NSRange) -> Void)) {
        let separatedArray: [String] = self.components(separatedBy: searchStr)
        if separatedArray.count < 2 { return }
        let count = separatedArray.count - 1
        let length = searchStr.utf16.count
        var location = 0
        for (index, item) in separatedArray.enumerated() {
            if index == count {
                return
            } else {
                location += item.utf16.count
                block(NSMakeRange(location, length))
                location += length
            }
        }
    }
}

//MARK: - Button Event Action
extension CaughterWindow {
    private func showWakeUpView() {
        self.windowStatus = false
        self.showLogView.isHidden = true
        self.wakeUpView.isHidden = false
    }
    
    private func showShowLogView() {
        self.windowStatus = true
        self.wakeUpView.isHidden = true
        self.showLogView.isHidden = false
    }
    
    private func sharing() {
        let toVC = UIActivityViewController(activityItems: self.caughter?.fileURL() ?? [], applicationActivities: .none)
        toVC.completionWithItemsHandler = { [weak self] (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ activityError: Error?) -> Void in
            guard let self = self else { return }
            if completed {
                self.caughter?.saveSuccess()
            }
        }
        self.rootViewController?.present(toVC, animated: true, completion: nil)
    }
}

//MARK: - Configure
extension CaughterWindow {
    private func configure() {
        if self.caughter == nil {
            self.caughter = LogCatchAndProcess()
        }
        self.caughter?.receiveDelegate = self
        self.rootViewController = UIViewController()
        self.windowLevel =  UIWindow.Level.statusBar + 1
        if (self.isKeyWindow) {
            self.resignKey()
        }
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.createWakeUpPage()
        self.createShowLogPage()
        self.showWakeUpView()
    
        NotificationCenter.default.addObserver(forName: NSNotification.Name("shake"), object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {
                return
            }
            if self.windowIsHidden {
                self.windowIsHidden = !self.windowIsHidden
                if self.windowStatus {
                    self.showLogView.isHidden = false
                } else {
                    self.wakeUpBtn.isHidden = false
                }
                return
            } else {
                self.rootViewController?.present(self.alertWindowForHidden, animated: true, completion: nil)
            }
        }
    }
    
    private func createWakeUpPage() {
        self.addSubview(self.wakeUpView)
        self.wakeUpView.frame = CGRect(x: wakeUpBtnPosition.x, y: wakeUpBtnPosition.y, width: sizeOfFloatBtn().x, height: sizeOfFloatBtn().y)
        self.wakeUpView.addSubview(self.wakeUpBtn)
        self.wakeUpView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:  #selector(floatBtnDragAction(gesture:))))
    }
    
    private func createShowLogPage() {
        self.addSubview(self.showLogView)
        self.showLogView.isUserInteractionEnabled = true
        self.showLogView.frame = CGRect(x: 0, y: SafeAreaTopH, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
        
        self.showLogView.addSubview(hideBtn)
        self.showLogView.addSubview(saveBtn)
        self.showLogView.addSubview(clearBtn)
        self.showLogView.addSubview(onOffBtn)
        self.showLogView.addSubview(searchBar)
//        self.showLogView.addSubview(textView)
        self.showLogView.addSubview(tableView)
        
        self.hideBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.saveBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-65)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.clearBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-120)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.onOffBtn.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-175)
            make.width.equalTo(50)
            make.height.equalTo(36)
        }
        self.searchBar.snp.makeConstraints{ (make) in
            make.height.equalTo(36)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-210)
            make.left.equalToSuperview()
        }
        self.tableView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(46 + 10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        self.searchBar.textField.delegate = self.searchBar
        self.searchBar.textField.addTarget(self, action: #selector(textFiledEditingChanged), for: .editingChanged)
        self.showLogView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:  #selector(logWindowDragAction(gesture:))))
    }
    
    @objc private func floatBtnAction(sender: UIButton) {
        self.showShowLogView()
        NSLog("floatBtnAction")
    }
    
    @objc private func hideBtnAction() {
        self.showWakeUpView()
        NSLog("hideBtnAction")
    }
    @objc private func saveBtnAction() {
        self.rootViewController?.present(alertWindowForShare, animated: true, completion: nil)
        NSLog("saveBtnAction")
    }
    @objc private func clearBtnAction() {
        self.caughter?.cleanAllAndStartAgain()
        self.rootViewController?.present(alertWindowForClear, animated: true, completion: nil)
        NSLog("clearBtnAction")
    }
    
    @objc private func onOffBtnAction() {
        guard let caughter = self.caughter  else {
            return
        }
        if caughter.switchState() {
            self.wakeUpBtn.setTitle("On", for: .normal)
            self.onOffBtn.setTitle("On", for: .normal)
            NSLog("State: On")
        } else {
            self.wakeUpBtn.setTitle("Off", for: .normal)
            self.onOffBtn.setTitle("Off", for: .normal)
            NSLog("State: Off")
        }
    }
    
    @objc private func textFiledEditingChanged(_ textField: UITextField) {
        updateData()
    }
    
    @objc private func floatBtnDragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .began:
            break
        case .changed:
            let point = gesture.translation(in: self.wakeUpView.superview)
            self.wakeUpView.center = CGPoint(x: self.wakeUpView.center.x + point.x, y: self.wakeUpView.center.y + point.y)
            if self.wakeUpView.center.y <= SafeAreaTopH + sizeOfFloatBtn().y/2 {
                self.wakeUpView.center.y = SafeAreaTopH + sizeOfFloatBtn().y/2
            } else if self.wakeUpView.center.y >= UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 - SafeAreaBottomH {
                self.wakeUpView.center.y = UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 - SafeAreaBottomH
            }
            break
        case .ended:
            let point = gesture.translation(in: self.wakeUpView.superview)
            var newPoint = CGPoint(x: self.wakeUpView.center.x + point.x, y: self.wakeUpView.center.y + point.y)
            
            if newPoint.x < UIScreen.main.bounds.width / 2.0 {
                newPoint.x = sizeOfFloatBtn().x/2 + sizeOfFloatBtn().edgeWidth
            } else {
                newPoint.x = UIScreen.main.bounds.width - sizeOfFloatBtn().x/2 - sizeOfFloatBtn().edgeWidth
            }
            UIView.animate(withDuration: 0.25) {
                self.wakeUpView.center = newPoint
            }
            self.wakeUpBtnPosition.x = self.center.x - sizeOfFloatBtn().x/2
            self.wakeUpBtnPosition.y = self.center.y - sizeOfFloatBtn().y/2
            break
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: self.wakeUpView.superview)
    }
    
    @objc func logWindowDragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .began:
            break
        case .changed:
            let point = gesture.translation(in: self.showLogView.superview)
            self.showLogView.center = CGPoint(x: self.showLogView.center.x, y: self.showLogView.center.y + point.y)
            if self.showLogView.center.y <= SafeAreaBottomH + sizeOfFloatBtn().y/2 {
                self.showLogView.center.y = SafeAreaBottomH + sizeOfFloatBtn().y/2
            } else if self.showLogView.center.y >= UIScreen.main.bounds.height - sizeOfFloatBtn().y/2 {
                self.showLogView.center.y = UIScreen.main.bounds.height - sizeOfFloatBtn().y/2
            }
            break
        case .ended:
            let point = gesture.translation(in: self.showLogView.superview)
            var newPoint = CGPoint(x: self.showLogView.center.x, y: self.showLogView.center.y + point.y)
            
            if newPoint.y <= SafeAreaTopH + self.showLogView.bounds.height/2 {
                newPoint.y = SafeAreaTopH + self.showLogView.bounds.height/2
            } else if newPoint.y >= UIScreen.main.bounds.height - self.showLogView.bounds.height/2 - SafeAreaBottomH {
                newPoint.y = UIScreen.main.bounds.height - self.showLogView.bounds.height/2 - SafeAreaBottomH
            }
            
            UIView.animate(withDuration: 0.25) {
                self.showLogView.center = newPoint
            }
            
            self.wakeUpBtnPosition.y = self.center.y - self.bounds.height/2
            break
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: self.showLogView.superview)
    }
}
extension CaughterWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.isUserInteractionEnabled || self.isHidden || self.alpha < 0.01) {
            return nil
        }
        if (self.point(inside: point, with: event)) {
            for subview in self.subviews.reversed() {
                let childPoint = self.convert(point, to: subview)
                let fitView = subview.hitTest(childPoint, with: event)
                if ((fitView) != nil && fitView != self.rootViewController?.view) {
                    return fitView
                }
            }
        }
        return nil
    }
}

extension CaughterWindow: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logAttr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogItemCellName) as? LogItemCell else { return UITableViewCell() }
        cell.bind(context: self.logAttr[indexPath.item])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
}

extension CaughterWindow {
    @objc func processGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                print("Long pressed row: \(indexPath.row)")
                
                UIPasteboard.general.string = self.logAttr[indexPath.item].string
                SVProgressHUD.showSuccess(withStatus: "复制成功")
            }
        }
    }
}

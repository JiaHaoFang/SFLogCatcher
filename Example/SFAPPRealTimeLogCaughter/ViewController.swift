//
//  ViewController.swift
//  SFAPPRealTimeLogCaughter
//
//  Created by 473993067@qq.com on 08/24/2021.
//  Copyright (c) 2021 473993067@qq.com. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    let period: Double = 0.1

    //MARK: - Subviews
    lazy var page: UIView = {
        let page = UIView()
        page.frame = self.view.bounds
        page.backgroundColor = .white
        return page
    }()
    private var btn: UIButton = {
        let btn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width/3, y: UIScreen.main.bounds.height/1.3, width: 100, height: 30))
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 12
        btn.setTitle("Timer", for: .normal)
        return btn
    }()
    private lazy var sw: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.isEnabled = false
        return s
    }()
    var timer1: Timer?
    var timer2: Timer?
        
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(page)
        self.view.addSubview(btn)
        self.view.addSubview(sw)
        self.btn.addTarget(self, action: #selector(Timer), for: .touchUpInside)
        
        self.sw.snp.makeConstraints{ (make) in
            make.left.equalTo(70)
            make.top.equalTo(UIScreen.main.bounds.height/1.3)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog("ClickBackground")
    }
    
    //MARK: - @objc
    @objc func Timer() {
        if timer1 == nil {
            DispatchQueue.main.async {
                self.sw.isOn = true
                self.timer1 = Foundation.Timer.scheduledTimer(timeInterval: self.period, target: self, selector: #selector(self.print1), userInfo: nil, repeats: true)
            }
        }
        if timer2 == nil {
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: self.period/2)
                self.sw.isOn = true
                self.timer2 = Foundation.Timer.scheduledTimer(timeInterval: self.period, target: self, selector: #selector(self.print2), userInfo: nil, repeats: true)
            }
        }
        
        if self.timer1 != nil {
            self.timer1?.invalidate()
            self.sw.isOn = false
            timer1 = nil

        }
        
        if self.timer2 != nil {
            self.timer2?.invalidate()
            self.sw.isOn = false
            timer2 = nil
        }
    }
    
    @objc func print1() {
        NSLog("Queue1🍔")
    }
    
    @objc func print2() {
        NSLog("Queue2🍞")
    }

}


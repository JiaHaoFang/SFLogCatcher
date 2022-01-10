//
//  SearchBarForWindow.swift
//  appDemo
//
//  Created by StephenFang on 2021/3/30.
//

import Foundation
import UIKit
import SnapKit

//MARK: - My SearchBar
class SearchBarForWindow: UIView, UITextFieldDelegate {
    
    //MARK: - Subviews
    var searchDelegate: SearchDelegate?
    public let textField = UITextField()
    private let grayBackground = UIView()
    private let cancelButton = UIButton()
    
    //MARK: - Configure
    public var isActive: Bool {
        return (self.textField.text == "") ? false : true
    }
    
    //MARK: - Init
    init() {
        super.init(frame: CGRect.zero)

        self.grayBackground.backgroundColor = MyColor().searchgray
        self.grayBackground.layer.cornerRadius = 12
        self.grayBackground.layer.masksToBounds = true
        
        self.textField.placeholder = "Search"
        self.textField.tintColor = MyColor().light
        self.textField.borderStyle = UITextField.BorderStyle.none
        self.textField.textAlignment = .left
        self.textField.clearButtonMode = .whileEditing
        self.textField.keyboardType = .default
        self.textField.clearButtonMode = .whileEditing
        self.textField.autocapitalizationType = .none
        
        self.addSubview(self.cancelButton)
        self.addSubview(self.grayBackground)
        self.grayBackground.addSubview(self.textField)
        
        self.grayBackground.snp.makeConstraints{ (make) in
            make.height.equalTo(36)
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20-10)
            make.right.equalToSuperview().offset(-20)
        }
        self.textField.snp.makeConstraints{ (make) in
            make.height.equalTo(36)
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12-5)
            make.right.equalToSuperview().offset(-10)
        }
            
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(textFiledEditingChanged(_:)), for: .editingChanged)
    }
    
    //MARK: - TF Delegate
    @objc func textFiledEditingChanged(_ textField: UITextField) {
        self.textField.text = textField.text
        searchDelegate?.search(self.textField.text ?? "")
    }
        
    //MARK: - LifeCycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SearchBarForWindow: ClearDelegate {
    func cleanSearchBarText() {
        self.textField.text = ""
    }
}

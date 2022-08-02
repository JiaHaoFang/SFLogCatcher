//
//  LogItemCell.swift
//  SFAPPRealTimeLogCaughter
//
//  Created by StephenFang on 2022/6/28.
//

import Foundation
import RxSwift

class LogItemCell: UITableViewCell {
    var cellDisposeBag = DisposeBag()
    
    lazy var logLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(context: NSAttributedString) {
        self.logLabel.attributedText = context
    }

    func layoutUI() {
        self.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 0.6)
        self.addSubview(self.logLabel)
        self.logLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
        }
        
        self.selectionStyle = .default
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellDisposeBag = DisposeBag()
    }
}

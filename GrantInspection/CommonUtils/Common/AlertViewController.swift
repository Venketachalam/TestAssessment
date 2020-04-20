//
//  AlertViewController.swift
//  GrantInspection
//
//  Created by Divya Lingam on 26/01/20.
//  Copyright © 2020 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlertType {
    case Upgrade
    case none
}
class AlertViewController: UIViewController {
    
    var contentView: UIView = {
        let content = UIView()
        content.backgroundColor = .white
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var titleLabel: UILabel = {
        let content = UILabel()
        content.font = UIFont.init(name: "DubaiW23-Bold", size: 20)
        content.textAlignment = .center
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var descriptionLabel: UILabel = {
        let content = UILabel()
        content.font = UIFont.init(name: "Dubai-Regular", size: 18)
        content.textAlignment = .center
        content.translatesAutoresizingMaskIntoConstraints = false
        content.numberOfLines = 0
        return content
    }()
    
    var okayButton: CustomButton = {
        let content = CustomButton()
        content.titleLabel?.font = UIFont.init(name: "Dubai-Regular", size: 18)
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var cancel: CustomButton = {
        let content = CustomButton()
        content.titleLabel?.font = UIFont.init(name: "Dubai-Regular", size: 18)
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var stackView: UIStackView = {
        let content = UIStackView()
        content.distribution = .equalSpacing
        content.spacing = 10
        content.axis = .horizontal
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var alertType:AlertType = .none
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addSubViews(type: alertType)
        self.view.backgroundColor = UIColor.navySemitransperent()
        if Common.currentLanguageArabic() {
            self.view.transform  = Common.arabicTransform
            self.view.toArabicTransform()
        }
        else
        {
            self.view.transform  = Common.englishTransform
            self.view.toEnglishTransform()
        }
        bindUpgradeUISetup()
    }
    
    private func bindUpgradeUISetup() {
               okayButton.rx.tap.subscribe {[weak self] event in
                          switch event {
                          case .next(_) :
                           self?.upgradeApp()
                           self?.hideAlert()
                          case .error(_),.completed:
                              break
                          }
                      }.disposed(by: disposeBag)
    
                      cancel.rx.tap.subscribe {[weak self] event in
                          switch event {
                          case .next(_) :
                           self?.hideAlert()
                          case .error(_),.completed:
                              break
                          }
                      }.disposed(by: disposeBag)
           }
    
         private func hideAlert() {
             DispatchQueue.main.async {
                Common.userDefaults.setUpgradeApp(isShowUpgrade: false)
                  self.dismiss(animated: true, completion: nil)
             }
         }
        func upgradeApp(){
            if let url = URL(string: "https://www.diawi.com/") {
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
            }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switch alertType {
        case .none :
            break
        case .Upgrade:
            addUpgradeViewConstrints()
        }
    }
    
    private func addSubViews(type: AlertType) {
        
        switch type {
        case .none :
            break
        case .Upgrade:
            addUpgradeAlertSubviews()
        }
    }
    
    private func addUpgradeAlertSubviews() {
        cancel.setTitle("NoThanks_btn".ls, for: .normal)
        okayButton.setTitle("Update_btn".ls, for: .normal)
        self.view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(cancel)
        stackView.addArrangedSubview(okayButton)
        descriptionLabel.text = "UpgradeDescription_lbl".ls
        titleLabel.text = "UpgradeTitle_lbl".ls
        titleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0).withAlphaComponent(1)
        descriptionLabel.textColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1.0).withAlphaComponent(1)
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
    }
    
    private func addUpgradeViewConstrints() {
        //contentView.borderWithCornerRadius()
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1.0
        contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        contentView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.20).isActive = true
        contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        stackView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.035).isActive = true
        // stackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.centerYAnchor, multiplier: 1.5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cancel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        okayButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        okayButton.type = .blue
        cancel.type = .lightGray
    }
}

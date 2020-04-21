//
//  CustomStepper.swift
//  GrantInspection
//
//  Created by Rajeswaran Thangaperumal on 30/08/2019.
//  Copyright © 2019 MBRHE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol StepperSelectionDelegate {
    func valueChange(index:Int,value:Int)
}

class CustomStepper : UIView {
    
    var contentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var increaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(red: 0/255, green: 192/255, blue: 176/255, alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(stepperAction(sender:)), for: .touchUpInside)
        button.tag = 100
        return button
    }()
    var decreaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.setTitleColor(UIColor(red: 249/255, green: 108/255, blue: 118/255, alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 101
        button.addTarget(self, action: #selector(stepperAction(sender:)), for: .touchUpInside)
        return button
    }()
    var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = "00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var rightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var centerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var delegate:StepperSelectionDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
        DispatchQueue.main.async {
            self.centerView.applyStyle()
            self.decreaseButton.applyStyle()
            self.increaseButton.applyStyle()
        }
        
        
    }
    
    private func setup() {
        
        leftView.addSubview(decreaseButton)
        rightView.addSubview(increaseButton)
        centerView.addSubview(valueLabel)
        self.stackView.addArrangedSubview(leftView)
        self.stackView.addArrangedSubview(centerView)
        self.stackView.addArrangedSubview(rightView)
        self.addSubview(stackView)
        addObserver()
        
    }
    
    private func addConstraints() {
        centerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        leftView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25).isActive = true
        decreaseButton.leadingAnchor.constraint(equalTo: leftView.leadingAnchor).isActive = true
        decreaseButton.rightAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
        decreaseButton.heightAnchor.constraint(equalTo: leftView.heightAnchor, multiplier: 0.8).isActive = true
        decreaseButton.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
        increaseButton.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
        increaseButton.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
        increaseButton.heightAnchor.constraint(equalTo: rightView.heightAnchor, multiplier: 0.8).isActive = true
        increaseButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: centerView.leadingAnchor).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: centerView.rightAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalTo: centerView.heightAnchor, multiplier: 0.8).isActive = true
        valueLabel.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    func addObserver() {
        decreaseButton.rx.tap.asObservable().subscribe { _ in
            self.increase(increase: false)
            }.disposed(by: DisposeBag())
        increaseButton.rx.tap.asObservable().subscribe { _ in
            self.increase(increase: true)
            }.disposed(by: DisposeBag())
    }
    
   
    
    func increase(increase:Bool) {
        var value = Int(valueLabel.text ?? "") ?? 0
        if increase {
            value = value + 1
        } else if value >= 1 {
            value = value - 1
        }
         valueLabel.text = String(format: "%02d", value)
        if let _ = delegate {
            delegate.valueChange(index: self.tag, value: value)
        }
    }
    
    @IBAction func stepperAction(sender: UIButton) {
        if sender.tag == 100 {
            increase(increase: true)
        } else {
            increase(increase: false)
        }
    }
}

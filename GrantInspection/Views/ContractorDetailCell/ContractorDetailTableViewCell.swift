//
//  ContractorDetailTableViewCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/18/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ContractorDetailTableViewCell: UITableViewCell {
   

    @IBOutlet weak var progressRing: UICircularProgressRing!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Customize some properties
       // progressRing.animationStyle = kCAMediaTimingFunctionLinear
        progressRing.style = .ontop
        progressRing.font = UIFont.init(name: "Dubai-Regular", size: 20)!
        progressRing.fontColor = UIColor.black
        // Set the delegate
        progressRing.delegate = self
        
        progressRing.startProgress(to: 0, duration: 0.3) { [weak self] in
            self?.progressRing.startProgress(to: 70, duration: 3, completion: {
                self?.progressRing.font = UIFont.init(name: "Dubai-Regular", size: 20)!
                print("progressRing finished")
            })
        }
       
//        progressRing.setProgress(value: 0, animationDuration: 0.5) { [unowned self] in
//            // Increase it more, and customize some properties
//            self.progressRing.setProgress(value: 70, animationDuration: 3) {
//                self.progressRing.font = UIFont.init(name: "Dubai-Regular", size: 20)!
//                print("progressRing finished")
//            }
//        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: UICircularProgressRingDelegate
//    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
//        if ring === progressRing {
//            print("From delegate: progressRing finished")
//        }
//    }
    
}

extension ContractorDetailTableViewCell: UICircularProgressRingDelegate {
    func didFinishProgress(for ring: UICircularProgressRing) {
        if ring === progressRing {
            print("From delegate: progressRing finished")
        }
    }
    
    func didPauseProgress(for ring: UICircularProgressRing) {
        
    }
    
    func didContinueProgress(for ring: UICircularProgressRing) {
        
    }
    
    func didUpdateProgressValue(for ring: UICircularProgressRing, to newValue: CGFloat) {
        
    }
    
    func willDisplayLabel(for ring: UICircularProgressRing, _ label: UILabel) {
        
    }
    
}

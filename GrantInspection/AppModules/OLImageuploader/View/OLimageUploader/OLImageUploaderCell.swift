//
//  NotesCustomCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 11/13/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit
import GTProgressBar


class OLImageUploaderCell: UITableViewCell {

  
  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var progress: UIView!
  
  var progressBar : GTProgressBar!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addProgressView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  func setData(model : OLDBModel){
    
    let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
        let filePathFetch = docDir.appendingPathComponent(model.fileName);
          if FileManager.default.fileExists(atPath: filePathFetch.path){
            if let containOfFilePath = UIImage(contentsOfFile : filePathFetch.path){
              thumbnail.image = containOfFilePath
            }
      }
    
    print(model.status)
    
    if model.status == "done"{
    
        btn2.setTitle("DONE".ls, for: .normal)
      btn2.setImage(UIImage(named: "Done_icon_green_bg"), for: .normal)
      btn2.setTitleColor(UIColor.black, for: .normal)
      btn2.isHidden = false
    }else if model.status == "toDo"{
          btn2.isHidden = true
//        btn2.setTitle("Cancel", for: .normal)
//        btn2.setImage(UIImage(named: "cancel_Icon"), for: .normal)
//        btn2.setTitleColor(UIColor.red, for: .normal)
    }
    
    progressBar.progress = CGFloat(model.percentage)
  
  }
  
  func addProgressView(){
    
    
    progressBar = GTProgressBar(frame: CGRect(x: 0, y: 0, width: self.progress.frame.size.width, height:self.progress.frame.size.height))
    progressBar.barBorderColor = UIColor(red:229/255, green:239/255, blue:245/255, alpha:1.0)
    progressBar.barFillColor = UIColor(red:0/255, green:97/255, blue:158/255, alpha:1.0)
    progressBar.barBackgroundColor = UIColor(red:242, green:247, blue:250, alpha:1.0)
    progressBar.barBorderWidth = 1
    progressBar.barFillInset = 2
    progressBar.labelTextColor = UIColor(red:0/255, green:97/255, blue:158/255, alpha:1.0)
    progressBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    progressBar.font = UIFont.boldSystemFont(ofSize: 18)
    progressBar.labelPosition = GTProgressBarLabelPosition.right
    progressBar.barMaxHeight = 10
    
    progress.addSubview(progressBar)
    
    
  }
  
  
}

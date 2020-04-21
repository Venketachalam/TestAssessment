//
//  BreakDownInnerCell.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/26/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import UIKit

protocol BreakDownProtocol {
  func addPercentage(dict : [String:String])
}

class BreakDownInnerCell: UITableViewCell , UITextFieldDelegate{
 
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contractPercentageTextField: UITextField!
    @IBOutlet weak var actualDoneTextField: UITextField!
    @IBOutlet weak var paymentTextField: UITextField!
    @IBOutlet weak var engineerTextField: UITextField!
    @IBOutlet weak var btnAddComment_Tapped: UIButton!
    @IBOutlet weak var engineeringPercentageView: MBRHEBorderView!
  
    var addDelegate : BreakDownProtocol?
    var paymentID : String = "" 
    var workID : String = ""
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
      contractPercentageTextField.delegate = self
      actualDoneTextField.delegate = self
      engineerTextField.delegate = self
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
    func textFieldDidEndEditing(_ textField: UITextField) {
    
  }
  
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    
    if textField == engineerTextField {
      
      if (textField.text?.count)! > 0 {
        
        var valueA : Float = Float(contractPercentageTextField.text!)!
        var valueB : Float = Float(actualDoneTextField.text!)!
        let TFvalue : Float = Float(textField.text!)!
        
        if valueB  < valueA { // if value B is Greater than value A , We swipe the values so contains func work
          let temp : Float = valueA
          valueA = valueB
          valueB = temp
        }
        
        if (valueA...valueB).contains(TFvalue) {
          
          let datDict : [String:String] = ["paymentID":self.paymentID,"workID":self.workID,"engineerPercentage":(self.engineerTextField.text?.description)!,"comment":"Lorem Ipsum"]
          
          if let delegate = self.addDelegate {
            delegate.addPercentage(dict: datDict)
          }
          self.engineeringPercentageView.layer.borderWidth = 1.0
          self.engineeringPercentageView.layer.borderColor = UIColor(red: 108/255, green: 129/255, blue: 155/255, alpha: 0.32).cgColor
          self.endEditing(true)
        } else {
          self.engineeringPercentageView.layer.borderWidth = 1.0
          self.engineeringPercentageView.layer.borderColor = UIColor(red: 245/255, green: 150/255, blue: 179/255, alpha: 1).cgColor
          self.engineerTextField.text = ""
         // self.engineerTextField.becomeFirstResponder()
        }
      }
    }
  }
}

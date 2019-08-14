//
//  BaseVC.swift
//  Kuwy
//
//  Created by Saikrishna Kumbhoji on 10/05/19.
//  Copyright © 2019 Saikrishna Kumbhoji. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    let serviceRequest = ServiceHelperClass()
    let alertControll = AlertHelperKit()
    let appUtil = AppUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT))
        DispatchQueue.main.async {
            let image = UIImage(named: "App_Background")
            imageView.image = image
            self.view.addSubview(imageView)
            self.view .sendSubviewToBack(imageView)
        }
    }
    override func viewWillLayoutSubviews() {

    }


}
struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

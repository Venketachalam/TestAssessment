//
//  RxSwift+NVActivityIndicatorView.swift
//  Progress
//
//  Created by Muhammad Akhtar on 10/16/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NVActivityIndicatorView

extension NVActivityIndicatorView {
    public var rx_animating: AnyObserver<Bool> {
        return Binder(self) { indicator, animating in
            if (animating) {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
            }.asObserver()
    }
}

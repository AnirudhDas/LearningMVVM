//
//  UIColorExtension.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func colorWithHex (_ hex : Int, alpha: CGFloat=1.0) -> UIColor {
        
        let cmp = (
            r : CGFloat(((hex >> 16) & 0xFF))/255.0,
            g : CGFloat(((hex >> 08) & 0xFF))/255.0,
            b : CGFloat(((hex >> 00) & 0xFF))/255.0
        )
        
        return UIColor(red: cmp.r, green: cmp.g, blue: cmp.b, alpha: alpha)
    }
}

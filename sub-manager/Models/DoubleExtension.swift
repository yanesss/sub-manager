//
//  DoubleExtension.swift
//  sub-manager
//
//  Created by aaron yanes on 7/18/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

/**
 ** post: double numbers can be rounded to specific decimal place
 */

import Foundation

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

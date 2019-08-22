//
//  StringExtension.swift
//  sub-manager
//
//  Created by aaron yanes on 7/18/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

/**
 ** Removes currency symbol from NumberFormatter
 */

import Foundation

extension String {
    func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol
        formatter.decimalSeparator = Locale.current.groupingSeparator
        return formatter.number(from: self)?.doubleValue ?? 0.00
    }
}

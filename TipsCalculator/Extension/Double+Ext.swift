//
//  Double+Ext.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/1/17.
//
//

import Foundation

struct Number {
    static let formatterWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "," // TODO: localize this
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var stringFormattedWithSeparator: String {
        return Number.formatterWithSeparator.string(from: self as! NSNumber) ?? ""
    }
}

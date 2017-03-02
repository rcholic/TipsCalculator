//
//  Double+Ext.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/1/17.
//
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

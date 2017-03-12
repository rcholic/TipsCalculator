//
//  Date+Ext.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/11/17.
//
//

import Foundation

extension Date {
    
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
}

//
//  Bill.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/11/17.
//
//

import Foundation

class Bill: NSObject, NSCoding {
    let billAmount: Double
    let tipsFraction: Float
    var timestamp: Date?
    
    init(billAmount: Double, tipsFraction: Float) {
        self.billAmount = billAmount
        self.tipsFraction = tipsFraction
        self.timestamp = Date() // current timestamp
    }
    
    required init(coder aDecoder: NSCoder) {
        self.billAmount = aDecoder.decodeDouble(forKey: "bill_amount")
        self.tipsFraction = aDecoder.decodeFloat(forKey: "tips_fraction")
        if aDecoder.containsValue(forKey: "timestamp") {
            self.timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
            return
        }
        self.timestamp = Date()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.billAmount, forKey:"bill_amount")
        aCoder.encode(self.tipsFraction, forKey:"tips_fraction")
        aCoder.encode(self.timestamp! as Date, forKey:"timestamp")
    }
    
    override var hash: Int {
        return timestamp?.hashValue ?? billAmount.hashValue
    }
}

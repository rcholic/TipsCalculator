//
//  Configuration.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/9/17.
//
//

import Foundation

struct Configuration {
    
    static var currencySymbol: String = NSLocale.current.currencySymbol ?? "$"
    static var language: String = Locale.current.languageCode ?? "en"
    
    typealias doneAction = () -> Void
    
    public static let shared = Configuration()
    
    fileprivate init() {}
    
    public func saveUserSettings(currencySymbol: String, tip percentage: Float, doneAction done: doneAction?) {
        print("saving user settings: \(currencySymbol), \(percentage) ")
        
        if DataManager.shared.save(currencySymbol, for: "CurrencySymbol") {
            print("success saving currency symbol!")
        } else {
            print("failed at saving currency symbol!")
        }
        DataManager.shared.save(percentage, for: "DefaultTipPct")
        
        guard let action = done else { return }
        action() // trigger the action
    }
    
}

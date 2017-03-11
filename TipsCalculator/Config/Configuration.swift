//
//  Configuration.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/9/17.
//
//

import Foundation

let CURRENCY_SYMBOL = "CurrencySymbol"
let TIPS_PERCENT = "DefaultTipPct"
let LOCAL_CURRENCY_SYMBOL = Locale.current.currencySymbol ?? "$"

struct Configuration {
    
    lazy var currencySymbol: String = {
        return DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String? ?? LOCAL_CURRENCY_SYMBOL
    }()
    
    static var language: String = Locale.current.languageCode ?? "en"
    
    typealias doneAction = () -> Void
    
    public static var shared = Configuration()
    
    fileprivate init() {}
    
    public func saveUserSettings(currencySymbol: String, tip percentage: Float, doneAction done: doneAction?) {
        
        let _ = DataManager.shared.save(currencySymbol, for: CURRENCY_SYMBOL)
        let _ = DataManager.shared.save(percentage, for: TIPS_PERCENT)
        
        guard let action = done else { return }
        action() // trigger the action
    }
    
}

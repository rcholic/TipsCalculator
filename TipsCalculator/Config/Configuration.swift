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
}

//
//  ViewController.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/1/17.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var subtotalTextField: UITextField!

    @IBOutlet weak var scratchLabel: ScratchLabel!
    
    @IBOutlet weak var tipSlider: TipSlider!
    
    var subtotalText = ""
    
    var subtotal: Double = 0
    
    var tipsPercentage: Double = 0.2 // 20%
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tipRecord = DataManager.shared.retrieve(for: "DefaultTipPct")
        let fraction = (tipRecord as! NSNumber).doubleValue
        tipSlider.fraction = CGFloat(fraction)
    }
    
    fileprivate func setupView() {
        setupNavbar()
        subtotalTextField.delegate = self
        tipSlider.delegate = self
        
        scratchLabel.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
        scratchLabel.delegate = self
        subtotalTextField.placeholder = "\(Configuration.currencySymbol)"
    }
    
    fileprivate func setupNavbar() {
        self.navigationController?.navigationBar.barTintColor = self.view.tintColor // UIColor.init(red: 0, green: 0.24, blue: 0.45, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Tips Calculator"
        let textShadow = NSShadow()
        textShadow.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        textShadow.shadowOffset = CGSize(width: 0, height: 1)
        let fontAttr = UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objects: [UIColor.white, textShadow, fontAttr!], forKeys: [NSForegroundColorAttributeName as NSCopying, NSShadowAttributeName as NSCopying, NSFontAttributeName as NSCopying]) as? [String : AnyObject]
    }
    
    
    @IBAction func didTapUserSettings(_ sender: Any) {
        
        if let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "UserSettingsVC") as? UserSettingsViewController {
           self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Construct the text that will be in the field if this change is accepted
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            subtotalText += string
            if let subtotal = formatCurrency(subtotalText) {
                self.subtotalTextField.text = "\(subtotal)"
            }
        default:
            if string.characters.count == 0 && subtotalText.characters.count != 0 {
                subtotalText = String(subtotalText.characters.dropLast())
                if let subtotal = formatCurrency(subtotalText) {
                    self.subtotalTextField.text = "\(subtotal)"
                }
            }
        }
        if let sub = Double(subtotalText) {
            scratchLabel.isHidden = false
            subtotal = sub/100.0
            self.scratchLabel.number = (1.0 + CGFloat(self.tipSlider.fraction)) * CGFloat(subtotal)
        } else {
            scratchLabel.isHidden = true
        }
        
        return false
    }
}

extension ViewController: ScratchLabelDelegate {
    func scratchLabel(_ scratchLabel: ScratchLabel, number: CGFloat) {
        print("number: \(number)")
        
        guard subtotal > 0 else {
            // hide the scratch and tip label here
            return
        }
        
        tipsPercentage = (Double(number) - subtotal) / subtotal
        let tipPct = (tipsPercentage * 100).roundTo(places: 2)
        self.tipSlider.fraction = CGFloat(tipsPercentage) // update tipSlider
    }
}

extension ViewController: TipSliderDelegate {
    func tipSlider(_ slider: TipSlider, value changedTo: Float) {

        guard subtotal > 0 else { return }
        print("slider value: \(changedTo), subtotal: \(subtotal)")
        
        self.scratchLabel.number = (1.0 + CGFloat(changedTo)) * CGFloat(subtotal)
    }
}

extension ViewController {
    
    func formatCurrency(_ string: String) -> String? {
        
        let count = string.characters.count
        
        if count > 1 {
            
            let firstIndex = string.index(string.startIndex, offsetBy: 1)
            
            if string.substring(from: firstIndex).replacingOccurrences(of: "0", with: " ", options: .literal, range: nil).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                return ""
            }
        }
    
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        var numberFromField = (NSString(string: string).doubleValue)/100
        return formatter.string(from: NSNumber(value: numberFromField))
//        println(textField.text )
    }
    
//    func formatCurrency(_ string: String) {
//        print("format \(string)")
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = findLocaleByCurrencyCode("USD")
//        let numberFromField = (NSString(string: subtotalText).doubleValue)/100
//        if let temp = formatter.string(from: NSNumber(value: numberFromField)) {
//            self.subtotalTextField.text = String(temp.characters.dropFirst())
//        }
//        
////        self.subtotalTextField.text = String(describing: temp!.characters.dropFirst())
//    }
//    
//    func findLocaleByCurrencyCode(_ currencyCode: String) -> Locale? {
//        
//        let locales = Locale.availableIdentifiers
//        var locale: Locale?
//        for   localeId in locales {
//            locale = Locale(identifier: localeId)
//            if let code = (locale! as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String {
//                if code == currencyCode {
//                    return locale
//                }   
//            } 
//        }
//        
//        return locale
//    }
}

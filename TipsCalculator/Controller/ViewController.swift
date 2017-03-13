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
    
    var tipAmount: Double = 0
    
    var tipsPercentage: Double = 0.0 // 20%
    
    var currencySymbol: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currencySymbol = LOCAL_CURRENCY_SYMBOL ?? DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String
            // DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as? String ?? LOCAL_CURRENCY_SYMBOL
        subtotalTextField.placeholder = currencySymbol
        subtotalTextField.becomeFirstResponder()
        
        let tipRecord = DataManager.shared.retrieve(for: TIPS_PERCENT)
        let fraction = (tipRecord as! NSNumber).floatValue
        tipSlider.fraction = CGFloat(fraction)
        let now = Date()
        guard let lastBill = DataManager.shared.retriveLastBill(), now.minutes(from: lastBill.timestamp) < TIME_DIFFERENCE_MIN else {
            NSLog("time diff is more than 10")
            return
        }

        // populate fields with the last bill within 10 minutes
        subtotal = lastBill.billAmount
        
        let localizedNumStr = NumberFormatter.localizedString(from: NSNumber(value: subtotal), number: NumberFormatter.Style.decimal)
        
        self.subtotalTextField.text = "\(currencySymbol)\(localizedNumStr)"
        self.tipSlider.fraction = CGFloat(lastBill.tipsFraction)
        self.scratchLabel.number = (1.0 + CGFloat(self.tipSlider.fraction)) * CGFloat(lastBill.billAmount)
        
        tipAmount = lastBill.billAmount * Double(lastBill.tipsFraction)
        self.scratchLabel.tipAmount = tipAmount
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard subtotal > 0 else { return }
        // save the bill
        let bill = Bill(billAmount: subtotal, tipsFraction: Float(tipsPercentage))
        let saved = DataManager.shared.saveBill(last: bill)
    }
    
    fileprivate func setupView() {
        setupNavbar()
        subtotalTextField.delegate = self
        tipSlider.delegate = self
        scratchLabel.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
        scratchLabel.delegate = self
    }
    
    fileprivate func setupNavbar() {
        self.navigationController?.navigationBar.barTintColor = self.view.tintColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Tip Calculator"
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
        
        if let sub = Double(subtotalText){
           subtotal = sub/100.0
            self.scratchLabel.number = (1.0 + CGFloat(self.tipSlider.fraction)) * CGFloat(subtotal)
            self.scratchLabel.tipAmount = Double(self.tipSlider.fraction) * subtotal
        }
        
        return false
    }
    
}

extension ViewController: ScratchLabelDelegate {
    func scratchLabel(_ scratchLabel: ScratchLabel, number: CGFloat) {
        
        guard subtotal > 0 else {
            // TODO: hide the scratch and tip label here
            return
        }
        
        tipsPercentage = (Double(number) - subtotal) / subtotal
        self.tipSlider.fraction = CGFloat(tipsPercentage) // update tipSlider
    }
}

extension ViewController: TipSliderDelegate {
    func tipSlider(_ slider: TipSlider, value changedTo: Float) {

        tipsPercentage = Double(changedTo) // update this variable
        guard subtotal > 0 else { return }
        
        self.scratchLabel.number = (1.0 + CGFloat(changedTo)) * CGFloat(subtotal)
        self.scratchLabel.tipAmount = Double(changedTo) * subtotal
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
        
        let numberFromField = (NSString(string: string).doubleValue)/100
        let localizedNumStr = NumberFormatter.localizedString(from: NSNumber(value: numberFromField), number: NumberFormatter.Style.decimal)

        return "\(currencySymbol)\(localizedNumStr)"
    }
}


//
//  UserSettingsViewController.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/9/17.
//
//

import UIKit

class UserSettingsViewController: UITableViewController {
    
    @IBOutlet weak var currencyTextField: UITextField!

    @IBOutlet weak var tipSlider: TipSlider!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var defaultTipPct: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.didTapDoneButton(sender:)))
        
        self.navigationItem.rightBarButtonItem = saveButton

        currencyTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        tipSlider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.isHidden = true
        currencyTextField.text = DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String? ?? LOCAL_CURRENCY_SYMBOL
            // Configuration.shared.currencySymbol
        currencyTextField.becomeFirstResponder()
        
        let tipRecord = DataManager.shared.retrieve(for: TIPS_PERCENT)
        let fraction = (tipRecord as! NSNumber).doubleValue 
        tipSlider.fraction = CGFloat(fraction)
    }
    
    @objc fileprivate func didTapDoneButton(sender: UIBarButtonItem) {
        
        let isValid = validateTextfield(textField: currencyTextField, charsRequired: 1, warnLabel: errorLabel)
        
        guard isValid else { return }
        
        Configuration.shared.saveUserSettings(currencySymbol: self.currencyTextField.text ?? Configuration.shared.currencySymbol, tip: Float(defaultTipPct)) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func textFieldDidChange(textField: UITextField) {
        let _ = validateTextfield(textField: textField, charsRequired: 1, warnLabel: errorLabel)
    }
    
    fileprivate func validateTextfield(textField: UITextField, charsRequired count: Int, warnLabel: UILabel) -> Bool {
        guard let text = textField.text, text.characters.count == count else {
            warnLabel.text = "Invalid Input: 1 chracter is required"
            warnLabel.isHidden = false
            return false
        }
        
        warnLabel.text = ""
        warnLabel.isHidden = true
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
}

extension UserSettingsViewController: TipSliderDelegate {
    
    func tipSlider(_ slider: TipSlider, value changedTo: Float) {
        defaultTipPct = CGFloat(changedTo)
    }
}

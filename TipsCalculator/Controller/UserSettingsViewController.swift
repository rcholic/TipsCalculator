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
        
        currencyTextField.delegate = self
        tipSlider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.isHidden = true
        currencyTextField.text = Configuration.shared.currencySymbol
        let tipRecord = DataManager.shared.retrieve(for: TIPS_PERCENT)
        let fraction = (tipRecord as! NSNumber).doubleValue 
        tipSlider.fraction = CGFloat(fraction)
    }
    
    @objc fileprivate func didTapDoneButton(sender: UIBarButtonItem) {
        
        guard let symbol = self.currencyTextField.text, symbol.characters.count == 1 else {
            errorLabel.text = "Invalid Input"
            errorLabel.isHidden = false
            return
        }
        
        errorLabel.text = ""
        errorLabel.isHidden = true
        
        Configuration.shared.saveUserSettings(currencySymbol: self.currencyTextField.text ?? Configuration.shared.currencySymbol, tip: Float(defaultTipPct)) {
            self.navigationController?.popViewController(animated: true)
        }
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

extension UserSettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let text = textField.text, text.characters.count == 1 else {
            
            errorLabel.text = "Invalid Input"
            errorLabel.isHidden = false
            return
        }
        
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text, text.characters.count == 1 else {
            
            errorLabel.text = "Invalid Input"
            errorLabel.isHidden = false
            return
        }
        
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
}

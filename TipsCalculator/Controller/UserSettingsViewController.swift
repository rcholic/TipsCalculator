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
    
    var defaultTipPct: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.didTapDoneButton(sender:)))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        tipSlider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tipRecord = DataManager.shared.retrieve(for: "DefaultTipPct")
        let fraction = (tipRecord as! NSNumber).doubleValue 
        tipSlider.fraction = CGFloat(fraction)
    }
    
    @objc fileprivate func didTapDoneButton(sender: UIBarButtonItem) {
        
        guard let symbol = self.currencyTextField.text, symbol.characters.count == 1 else {
            print("symbol is nil, dude")
            return
        }
        
        Configuration.shared.saveUserSettings(currencySymbol: self.currencyTextField.text ?? "$", tip: Float(defaultTipPct)) {
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

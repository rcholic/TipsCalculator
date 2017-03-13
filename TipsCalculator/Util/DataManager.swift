//
//  DataManager.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/10/17.
//
//

import Foundation

struct DataManager {
    
    public static let shared = DataManager()
    
    fileprivate var docDirectory: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = paths.first
        return docDir
    }
    
    var dataFilePath: String? {
        guard let docPath = self.docDirectory else { return nil }
        return docPath.appending("/Data.plist")
    }
    
    var dict: NSMutableDictionary? {
        guard let filePath = self.dataFilePath else { return nil }
        return NSMutableDictionary(contentsOfFile: filePath)
    }
    
    let fileManager = FileManager.default
    
    fileprivate init() {
        
        guard let path = dataFilePath else {
            return
        }
        
        guard fileManager.fileExists(atPath: path) else {
//            NSLog("Creating Data.plist")
//            fileManager.createFile(atPath: path, contents: nil, attributes: nil) // create the file
//            NSLog("created Data.plist file successfully")
            
            if let bundlePath = Bundle.main.path(forResource: "Data", ofType: "plist") {
                do {
                    let fromURL = NSURL(string: bundlePath)! // URL(string: bundlePath)!
                    let toURL = NSURL(string: path)!
                    try fileManager.copyItem(at: fromURL as URL, to: toURL as URL)
                    NSLog("Copied Data.plist to Document directory")
                } catch let error {
                    NSLog("Error in copying Data.plist: \(error)")
                }
            } else {
                NSLog("cannot find main bundle")
            }
            
            return
        }
    }
    
    func save(_ value: Any, for key: String) -> Bool {
        guard let dict = dict else { return false }
        
        dict.setObject(value, forKey: key as NSCopying)
        dict.write(toFile: dataFilePath!, atomically: true)
        
        return true
    }
    
    func delete(key: String) -> Bool {
        guard let dict = dict else { return false }
        dict.removeObject(forKey: key)
        return true
    }
    
    func retrieve(for key: String) -> Any? {
        guard let dict = dict else { return false }
        
        return dict.object(forKey: key)
    }
    
    func saveBill(last bill: Bill) -> Bool {
        let encoded = NSKeyedArchiver.archivedData(withRootObject: bill)
        NSLog("saving bill: \(bill)")
        return save(encoded, for: BILL_KEY)
    }
    
    func retriveLastBill() -> Bill? {
        guard let encoded = retrieve(for: BILL_KEY) as? Data,
            let bill = NSKeyedUnarchiver.unarchiveObject(with: encoded) as? Bill else {
            return nil
        }
        NSLog("retrieving bill: \(bill)")
        
        return bill
    }
}

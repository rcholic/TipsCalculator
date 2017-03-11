//
//  DataManager.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/10/17.
//
//

import Foundation

struct DataManager {
    
    public static var shared = DataManager()
    
    fileprivate var docDirectory: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = paths.first
        return docDir
    }
    
    var dataFilePath: String? {
        guard let docPath = self.docDirectory else { return nil }
        return docPath.appending("Data.plist")
    }
    
    var dict: NSMutableDictionary? {
        guard let filePath = self.dataFilePath else { return nil }
        return NSMutableDictionary(contentsOfFile: filePath)
    }
    
    let fileManager = FileManager.default
    
    fileprivate init() {
        
        guard let path = dataFilePath else { return }
        guard fileManager.fileExists(atPath: path) else {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil) // create the file
            print("created Data.plist file successfully")
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
}

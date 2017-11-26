//
//  FileProcessor.swift
//  NibleSoft
//
//  Created by Иван on 01.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

public class FileProcessor {
    //Путь к папке с документами
    class func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //Путь к файлу
    class func dataFilePath(name: String) -> URL {
        return documentsDirectory().appendingPathComponent("\(name).plist")
    }
    
    //Сохраняет в файл предыдущие запросы
    class func saveChecklistItems(items: [[String: String]], key: String) {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(items, forKey: key)
        archiver.finishEncoding()
        data.write(to: dataFilePath(name: key), atomically: true)
    }
    
    //Считывает из файла предыдущие запросы
    class func loadChecklistItems(key: String) -> [[String: String]] {
        var items = [[String: String]]()
        
        let path = dataFilePath(name: key)
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            items = unarchiver.decodeObject(forKey: key) as! [[String: String]]
            unarchiver.finishDecoding()
        }
        
        return items
    }
    
}

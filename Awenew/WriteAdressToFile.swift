//
//  WriteAdressToFile.swift
//  Awenew
//
//  Created by Иван on 04.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

class WriteAdressToFile {
    class func write(adress: [String], latitude: Double, longitude: Double) {
        // Будет хранить текущий запрос
        var currentItem = [String: String]()
        // Массив словарей с предыдущими запросами
        var allItems = [[String: String]]()
        
        // Получаем дату в виде строки
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        //Получили строку из времени
        let date = formatter.string(from: Date())
        
        // Записываем дату запроса
        currentItem["Date"] = date
        // Записываем адрес, при котором был сделан запрос
        currentItem["Adress"] = adress[0]
        // Записываем широту
        currentItem["Latitude"] = String(format: "%.7f", latitude)
        // Записываем долготу
        currentItem["Longitude"] = String(format: "%.7f", longitude)
        // Записываем город
        currentItem["City"] = adress[1]
        // Записываем часы
        currentItem["Hours"] = String(NSCalendar.current.component(.hour, from: Date()))
        
        // Считали предыдущие записи из файла
        allItems = FileProcessor.loadChecklistItems(key: "PreviousRequests")
        // Добавили новую запись о местоположении в конец массива
        allItems.append(currentItem)
        
        // Сохранили изменения в файле
        FileProcessor.saveChecklistItems(items: allItems, key: "PreviousRequests")
    }
}

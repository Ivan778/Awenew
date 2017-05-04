//
//  WriteWeatherToFile.swift
//  WeatherApp
//
//  Created by Иван on 04.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

class WriteWeatherToFile {
    // Пишет погоду в файл
    class func write(weather: Weather) {
        // Будет хранить текущий запрос
        var currentItem = [String: String]()
        // Массив словарей с предыдущими запросами
        var allItems = [[String: String]]()
        
        currentItem["Temperature"] = "\(weather.temperature) °C"
        currentItem["Humidity"] = "\(weather.humidity) %"
        currentItem["Pressure"] = "\(weather.pressure) мм рт. ст."
        currentItem["Icon"] = weather.icon
        
        allItems = FileProcessor.loadChecklistItems(key: "PreviousWeatherRequests")
        allItems.append(currentItem)
        
        FileProcessor.saveChecklistItems(items: allItems, key: "PreviousWeatherRequests")
    }
}

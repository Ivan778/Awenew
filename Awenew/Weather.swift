//
//  Weather.swift
//  Awenew
//
//  Created by Иван on 30.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

// Структура для хранения погодной записи
@objc class Weather: NSObject {
    let temperature: Int
    let pressure: Int
    let humidity: Int
    let descr: String
    let icon: String
    
    // Инициализируем структуру
    init(temperature: Int, pressure: Int, humidity: Int, description: String, icon: String) {
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
        self.descr = description
        self.icon = icon
    }
}

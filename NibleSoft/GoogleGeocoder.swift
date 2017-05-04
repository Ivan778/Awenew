//
//  GoogleGeocoder.swift
//  NibleSoft
//
//  Created by Иван on 01.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

protocol GoogleGeocoderDelegate {
    func didGetAdress(adress: [String])
    func didNotGetAdress(error: NSError)
}

class GoogleGeocoder {
    private let googleMapsGeocoderBaseAPI = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
    private let googleMapsGeocoderAPIKey = "AIzaSyCnhPsgYc7yrvi8i5BCZhQ1HzvyA02X7gg"
    private var delegate: GoogleGeocoderDelegate
    
    init(delegate: GoogleGeocoderDelegate) {
        self.delegate = delegate
    }
    
    func getAdress(latitude: String, longitude: String) {
        let session = URLSession.shared
        
        // Создали ссылку для запроса
        let url = String("\(googleMapsGeocoderBaseAPI)\(latitude),\(longitude)&key=\(googleMapsGeocoderAPIKey)")!
        
        let reverseGeocoderURLSession = URL(string: url)!
        let dataTask = session.dataTask(with: reverseGeocoderURLSession) { (data, response, error) in
            if let networkError = error {
                print("Ошибка! GoogleGeocoder - \(networkError)")
                self.delegate.didNotGetAdress(error: networkError as NSError)
            }
            else {
                do {
                    // Получили данные в виде словаря
                    let reverseGeocodeData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    // Здесь будем хранить адрес
                    var adress = String()
                    // Получили полный адрес (страна, город, улица, номер дома)
                    if let results = reverseGeocodeData["results"] as? NSArray {
                        if let results0 = results[0] as? NSDictionary {
                            if let formatted_address = results0["formatted_address"] as? String {
                                adress = formatted_address
                            }
                        }
                    }
                    
                    // Здесь будем хранить город
                    var city = String()
                    // Получаем имя города
                    if let results = reverseGeocodeData["results"] as? NSArray {
                        if let results0 = results[0] as? NSDictionary {
                            if let address_components = results0["address_components"] as? NSArray {
                                if let address_components3 = address_components[3] as? NSDictionary {
                                    if let long_name = address_components3["long_name"] as? String {
                                        city = long_name
                                    }
                                }
                            }
                        }
                    }
                    
                    // Выводим полный адрес и город в консоль
                    //print(adress)
                    //print("Город: \(city)")
                    
                    // Отправляем данные в WeatherAndNavigationViewController
                    self.delegate.didGetAdress(adress: [adress, city])
                    
                }
                catch let jsonError as NSError {
                    print("Ошибка JSON: \(jsonError)")
                    self.delegate.didNotGetAdress(error: jsonError)
                }
            }
        }
        
        // Если соединение с интернетом есть, то запускаем сессию, которая отправит запрос на погоду
        if Reachability.isConnectedToNetwork() == true {
            dataTask.resume()
        } else {
            self.delegate.didNotGetAdress(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
        
        
    }
}

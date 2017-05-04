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
                    
                    var adress = String()
                    
                    if let first = reverseGeocodeData["results"] as? NSArray {
                        if let value = first[0] as? NSDictionary {
                            if let d = value["formatted_address"] as? String {
                                adress = d
                            }
                        }
                    }
                    
                    var city = String()
                    
                    if let first = reverseGeocodeData["results"] as? NSArray {
                        if let value = first[0] as? NSDictionary {
                            if let d = value["address_components"] as? NSArray {
                                if let c = d[3] as? NSDictionary {
                                    if let t = c["long_name"] as? String {
                                        city = t
                                    }
                                }
                            }
                        }
                    }
                    
                    print(adress)
                    print("Город: \(city)")
                    
                    self.delegate.didGetAdress(adress: [adress, city])
                    
                }
                catch let jsonError as NSError {
                    print("Ошибка JSON: \(jsonError)")
                    self.delegate.didNotGetAdress(error: jsonError)
                }
            }
        }
        
        if Reachability.isConnectedToNetwork() == true {
            dataTask.resume()
        } else {
            self.delegate.didNotGetAdress(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
        
        
    }
}

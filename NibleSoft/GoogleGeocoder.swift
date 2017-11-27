//
//  GoogleGeocoder.swift
//  NibleSoft
//
//  Created by Иван on 01.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

@objc protocol GoogleGeocoderDelegate {
    @objc optional func didGetAdress(adress: [String])
    @objc optional func didNotGetAdress(error: NSError)
    
    @objc optional func didGetCoordinates(coordinates: [String])
    @objc optional func didNotGetCoordinates(error: NSError)
}

class GoogleGeocoder {
    private let googleMapsGeocoderBaseURL = "https://maps.googleapis.com/maps/api/geocode/json?"
    private let latLon = "latlng="
    private let placeId = "place_id="
    private let googleMapsGeocoderAPIKey = "AIzaSyCnhPsgYc7yrvi8i5BCZhQ1HzvyA02X7gg"
    private var delegate: GoogleGeocoderDelegate
    
    init(delegate: GoogleGeocoderDelegate) {
        self.delegate = delegate
    }
    
    func getCoordinatesByID(ID: String) {
        let url = String("\(googleMapsGeocoderBaseURL)\(placeId)\(ID)&key=\(googleMapsGeocoderAPIKey)")!
        
        let session = URLSession.shared
        let getCoordinatesSession = URL(string: url)!
        
        let dataTask = session.dataTask(with: getCoordinatesSession) { (data, response, error) in
            if let networkError = error {
                self.delegate.didNotGetCoordinates!(error: networkError as NSError)
            }
            else {
                do {
                    let res = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                    if res["status"] as! String == "OK" {
                        self.delegate.didGetCoordinates!(coordinates: self.parseIDResponse(response: res["results"] as! NSArray))
                    } else {
                        self.delegate.didNotGetCoordinates!(error: NSError(domain: "Данные не получены!", code: 111))
                    }
                    
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetCoordinates!(error: jsonError)
                }
            }
        }
        
        
        if Reachability.isConnectedToNetwork() {
            dataTask.resume()
        } else {
            self.delegate.didNotGetCoordinates!(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
 
    }
    
    func getAddress(latitude: String, longitude: String) {
        let url = String("\(googleMapsGeocoderBaseURL)\(latLon)\(latitude),\(longitude)&key=\(googleMapsGeocoderAPIKey)")!
        
        let session = URLSession.shared
        let reverseGeocoderURLSession = URL(string: url)!
        
        let dataTask = session.dataTask(with: reverseGeocoderURLSession) { (data, response, error) in
            if let networkError = error {
                print("Ошибка! GoogleGeocoder - \(networkError)")
                self.delegate.didNotGetAdress!(error: networkError as NSError)
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
                    
                    // Отправляем данные в WeatherAndNavigationViewController
                    self.delegate.didGetAdress!(adress: [adress, city])
                    
                }
                catch let jsonError as NSError {
                    print("Ошибка JSON: \(jsonError)")
                    self.delegate.didNotGetAdress!(error: jsonError)
                }
            }
        }
        
        if Reachability.isConnectedToNetwork() {
            dataTask.resume()
        } else {
            self.delegate.didNotGetAdress!(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
        
    }
    
    func parseIDResponse(response: NSArray) -> [String] {
        var result = [String]()
        
        let location = ((response[0] as AnyObject)["geometry"] as AnyObject)["location"] as AnyObject
        result.append(String("\(location["lat"] as! Double)"))
        result.append(String("\(location["lng"] as! Double)"))
        
        return result
    }
}

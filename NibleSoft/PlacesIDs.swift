//
//  GetPlaceCoordinates.swift
//  WeatherApp
//
//  Created by Иван on 26.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

@objc protocol PlacesIDsDelegate {
    func didGetList(items: [String: String]);
    func didNotGetList(error: NSError);
}

class PlacesIDs {
    private let baseURL = "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?&key=";
    private let APIKey = "AIzaSyBIuCUfN9yizrJCXhqstUM3LQLwB9hC0zw"
    private let field = "&input="
    
    private var delegate: PlacesIDsDelegate
    
    init(delegate: PlacesIDsDelegate) {
        self.delegate = delegate
    }
    
    func getListOfItems(searchPhrase: String) {
        let url = String("\(baseURL)\(APIKey)\(field)\(searchPhrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
        
        let session = URLSession.shared
        let getCoordinatesSession = URL(string: url)!
        
        let dataTask = session.dataTask(with: getCoordinatesSession) { (data, response, error) in
            if let networkError = error {
                self.delegate.didNotGetList(error: networkError as NSError)
            }
            else {
                do {
                    let res = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                    if res["status"] as! String == "OK" {
                        self.delegate.didGetList(items: self.parseResponse(response: res["predictions"] as! NSArray))
                    } else {
                        self.delegate.didNotGetList(error: NSError(domain: "Данные не получены!", code: 111))
                    }
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetList(error: jsonError)
                }
            }
        }
        
        if Reachability.isConnectedToNetwork() == true {
            dataTask.resume()
        } else {
            self.delegate.didNotGetList(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
    }
    
    func parseResponse(response: NSArray) -> [String: String] {
        var items = [String: String]()
        
        for item in response {
            if let types = (item as AnyObject)["types"] as? NSArray {
                if types.contains("locality") || types.contains("country") {
                    items[(item as AnyObject)["description"] as! String] = (item as AnyObject)["place_id"] as? String
                }
            }
            
        }
        
        return items
    }
}

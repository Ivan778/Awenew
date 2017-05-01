//
//  WeatherReceiver.swift
//  NibleSoft
//
//  Created by Иван on 30.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

protocol WeatherReceiverDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: NSError)
}

class WeatherReceiver {
    private let openWeatherBaseURL = "http://api.openweathermap.org/data/2.5/weather?"
    private let openWeatherAPIKey = "e04251aa322f414ec1779b3b8c3f9286"
    private var delegate: WeatherReceiverDelegate
    
    init(delegate: WeatherReceiverDelegate) {
        self.delegate = delegate
    }
    
    public func getWeather(latitude: String, longitude: String) {
        let session = URLSession.shared
        
        // Ссылка на запрос погоды по широте и долготе
        let url = String("\(openWeatherBaseURL)lat=\(String(latitude)!)&lon=\(String(longitude)!)&APPID=\(openWeatherAPIKey)")!
        let weatherURLSession = URL(string: url)!
        
        // Запрашиваем JSON с данными о погоде
        let dataTask = session.dataTask(with: weatherURLSession) { (data, response, error) in
            if let networkError = error {
                self.delegate.didNotGetWeather(error: networkError as NSError)
                print("Ошибка! WeatherReceiver - \(networkError)")
            }
            else {
                do {
                    // Получили данные о погоде
                    let weather = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    // Извлекли значение температуру
                    let temperature = (weather["main"]!["temp"]!! as! Int - 273)
                    // Извлекли значение влажности
                    let humidity = (weather["main"]!["humidity"]!! as! Int)
                    // Извлекли значение давления
                    let pressure = Int((weather["main"]!["pressure"]!! as! Double) * 100 / 133.3)
                    
                    // Извлекаем описание погоды
                    var description = String()
                    var icon = String()
                    if let w = weather["weather"] as? NSArray {
                        if let value = w[0] as? NSDictionary {
                            if let d = value["description"] as? String {
                                description = self.translateDescription(description: d)
                                icon = (value["icon"] as? String)!
                            }
                        }
                    }
                    
                    
                    if Reachability.isConnectedToNetwork() == true {
                        let forWeatherDelegate = Weather(temperature: temperature, pressure: pressure, humidity: humidity, description: description, icon: icon)
                    
                        self.delegate.didGetWeather(weather: forWeatherDelegate)
                    }
                    
                    print("\(temperature) °C, \(description)\nВлажность: \(humidity) %\nДавление: \(pressure) мм рт. ст.")
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetWeather(error: jsonError)
                    print("Ошибка JSON: \(jsonError)")
                }
            }
        }
        
        dataTask.resume()
        
    }
    
    // Переводит описание погоды. Нужно дополнить базу
    public func translateDescription(description: String) -> String {
        var translation = String()
        
        switch description {
            case "clear sky": translation = "ясное небо"; break
            case "few clouds": translation = "переменная облачность"; break
            case "scattered clouds": translation = "незначительная облачность"; break
            case "broken clouds": translation = "облачно с прояснениями"; break
            case "shower rain": translation = "проливной дождь"; break
            case "rain": translation = "дождь"; break
            case "thunderstorm": translation = "гроза"; break
            case "snow": translation = "снег"; break
            case "mist": translation = "туманно"; break
            
            default: translation = "Ошибка!"; print(description)
        }
        
        return translation
    }
    
}

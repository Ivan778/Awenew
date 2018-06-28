//
//  WeatherReceiver.swift
//  Awenew
//
//  Created by Иван on 30.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

@objc protocol WeatherReceiverDelegate {
    @objc optional func didGetWeather(weather: Weather)
    @objc optional func didNotGetWeather(error: NSError)
    
    @objc optional func didGetForecast(forecast: [Weather])
    @objc optional func didNotGetForecast(error: NSError)
}

class WeatherReceiver {
    private let openWeatherBaseURL = "http://api.openweathermap.org/data/2.5/"
    private let field1 = "weather?"
    private let field2 = "forecast?"
    private let openWeatherAPIKey = "e04251aa322f414ec1779b3b8c3f9286"
    private var delegate: WeatherReceiverDelegate
    
    init(delegate: WeatherReceiverDelegate) {
        self.delegate = delegate
    }
    
    public func getWeather(latitude: String, longitude: String) {
        let session = URLSession.shared
        
        // Ссылка на запрос погоды по широте и долготе
        let url = "\(openWeatherBaseURL)\(field1)lat=\(latitude)&lon=\(longitude)&APPID=\(openWeatherAPIKey)"
        let weatherURLSession = URL(string: url)!
        
        // Запрашиваем JSON с данными о погоде
        let dataTask = session.dataTask(with: weatherURLSession) { (data, response, error) in
            if let networkError = error {
                self.delegate.didNotGetWeather!(error: networkError as NSError)
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
                    
                    // Создаём структуру с описанием погоды, которую отправим в WeatherAndNavigationViewController
                    let forWeatherDelegate = Weather(temperature: temperature, pressure: pressure, humidity: humidity, description: description, icon: icon)
                    // Отправляем данные в WeatherAndNavigationViewController
                    self.delegate.didGetWeather!(weather: forWeatherDelegate)
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetWeather!(error: jsonError)
                    print("Ошибка JSON: \(jsonError)")
                }
            }
        }
        
        if Reachability.isConnectedToNetworkNow() {
            dataTask.resume()
        } else {
            self.delegate.didNotGetWeather!(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
    }
    
    func getForecast(coordinates: [String]) {
        let session = URLSession.shared
        
        // Ссылка на запрос погоды по широте и долготе
        let url = "\(openWeatherBaseURL)\(field2)units=metric&lat=\(coordinates[0])&lon=\(coordinates[1])&APPID=\(openWeatherAPIKey)"
        let weatherURLSession = URL(string: url)!
        
        // Запрашиваем JSON с данными о погоде
        let dataTask = session.dataTask(with: weatherURLSession) { (data, response, error) in
            if let networkError = error {
                self.delegate.didNotGetForecast!(error: networkError as NSError)
                print("Ошибка! WeatherReceiver - \(networkError)")
            }
            else {
                do {
                    // Получили данные о погоде
                    let forecast = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    let list = forecast["list"] as? NSArray
                    
                    let forecastList = self.extractForecastList(list: list!)
                    
                    self.delegate.didGetForecast!(forecast: forecastList)
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetWeather!(error: jsonError)
                    print("Ошибка JSON: \(jsonError)")
                }
            }
        }
        
        if Reachability.isConnectedToNetworkNow() {
            dataTask.resume()
        } else {
            self.delegate.didNotGetForecast!(error: NSError(domain: "Нет соединения с интернетом!", code: 404))
        }
    }
    
    func extractForecastList(list: NSArray) -> [Weather] {
        var forecastList = [Weather]()
        
        for item in list {
            var temp = 0
            var press = 0
            var humid = 0
            var icon = ""
            
            if let main = (item as AnyObject)["main"] as? AnyObject {
                temp = (main["temp"] as? Int)!
                press = Int((main["pressure"] as? Double)! * 100 / 133.3) 
                humid = (main["humidity"] as? Int)!
            }
            if let weather = (item as AnyObject)["weather"] as? AnyObject {
                icon = ((weather[0] as AnyObject)["icon"] as? String)!
            }
            
            let date = self.dateConverter(date: ((item as AnyObject)["dt_txt"] as? String)!)
            
            let weather = Weather(temperature: temp, pressure: press, humidity: humid, description: date, icon: icon)
            forecastList.append(weather)
        }
        
        return forecastList
    }
    
    func dateConverter(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: date)!
        
        dateFormatter.dateFormat = "EEEE, HH:mm"
        return dateFormatter.string(from: myDate)
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

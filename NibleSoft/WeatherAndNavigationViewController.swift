//
//  WeatherAndNavigationViewController.swift
//  NibleSoft
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherAndNavigationViewController: UIViewController, CLLocationManagerDelegate, WeatherReceiverDelegate, GoogleGeocoderDelegate {
    // Ссылка на Label, который будет отображать широту
    @IBOutlet weak var latitudeLabel: UILabel!
    // Ссылка на Label, который будет отображать адрес местоположения пользователя
    @IBOutlet weak var adressLabel: UILabel!
    // Ссылка на Label, который будет отображать температуру
    @IBOutlet weak var temperatureAndDescriptionLabel: UILabel!
    // Ссылка на Label, который будет отображать значение влажности
    @IBOutlet weak var humidityLabel: UILabel!
    // Ссылка на Label, который будет отображать значение давления
    @IBOutlet weak var pressureLabel: UILabel!
    // Ссылка на ImageView, который будет отображать картинку погоды
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    // Нужно для локации
    let locationManager = CLLocationManager()
    // Будет хранить координаты
    var location: CLLocation?
    
    var wroteWeather = false
    var wroteLocation = false
    
    // Для получения погоды
    var weather: WeatherReceiver!
    // Для получения адреса
    var reverseGeocoder: GoogleGeocoder!
    
    // Блокирует кнопки TabBar
    func blockBarButtons() {
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            
            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Блокируем кнопки TabBar, чтобы пользователь не мог перейти, когда осуществляется подгрузка данных о погоде
        blockBarButtons()
        
        FileProcessor.saveChecklistItems(items: [[String: String]](), key: "PreviousRequests")
        FileProcessor.saveChecklistItems(items: [[String: String]](), key: "PreviousWeatherRequests")
        
        // Для протоколов
        weather = WeatherReceiver(delegate: self)
        reverseGeocoder = GoogleGeocoder(delegate: self)
        
        latitudeLabel.text = ""
        adressLabel.text = ""
        
        // Инициализируем LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let currentHours = NSCalendar.current.component(.hour, from: Date())
        
        if (currentHours > 20 || currentHours < 5) {
            self.view.backgroundColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 112.0/255.0, alpha: 1)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // Записывает в latitudeLabel и longitudeLabel широту и долготу
    func updateLabels() {
        if let loc = location {
            latitudeLabel.text = String(format: "%.7f", loc.coordinate.latitude) + ", " + String(format: "%.7f", loc.coordinate.longitude)
        } else {
            latitudeLabel.text = String("-/-, -/-")
        }
    }
    
    // Принимает данные о погоде и выводит их на экран
    func didGetWeather(weather: Weather) {
        print("didGetWeather")
        
        DispatchQueue.main.async {
            if self.wroteWeather == false {
                // Записываем данные о погоде в их Label-ы
                self.temperatureAndDescriptionLabel.text = "\(weather.temperature) °C"
                self.humidityLabel.text = "\(weather.humidity) %"
                self.pressureLabel.text = "\(weather.pressure) мм рт. ст."
                self.weatherIconImageView.image = UIImage(named: weather.icon)
                
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
                self.wroteWeather = true
            }
            
        }
    }
    
    // Принимает данные об ошибке, из-за которой не была определена погода, и выводит её на экран
    func didNotGetWeather(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Отображаем изменения на экране
        self.temperatureAndDescriptionLabel.text = "-/-"
        self.humidityLabel.text = "-/-"
        self.pressureLabel.text = "-/-"
    }
    
    // Принимает адрес и выводит его на экран
    func didGetAdress(adress: [String]) {
        print("didGetAdress")
        
        DispatchQueue.main.async {
            if self.wroteLocation == false {
                self.adressLabel.text = adress[0]
                
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
                currentItem["Latitude"] = String(format: "%.7f", (self.location?.coordinate.latitude)!)
                // Записываем долготу
                currentItem["Longitude"] = String(format: "%.7f", (self.location?.coordinate.longitude)!)
                // Записываем город
                currentItem["City"] = adress[1]
                // Записываем часы
                currentItem["Hours"] = String(NSCalendar.current.component(.hour, from: Date()))
                
                allItems = FileProcessor.loadChecklistItems(key: "PreviousRequests")
                allItems.append(currentItem)
                
                FileProcessor.saveChecklistItems(items: allItems, key: "PreviousRequests")
                
                let tabBarControllerItems = self.tabBarController?.tabBar.items
                
                if let tabArray = tabBarControllerItems {
                    let tabBarItem1 = tabArray[0]
                    let tabBarItem2 = tabArray[1]
                    
                    tabBarItem1.isEnabled = true
                    tabBarItem2.isEnabled = true
                }
                self.wroteLocation = true
            }
            
        }
    }
    
    // Принимает данные об ошибке, из-за которой не был определён адрес, и выводит её на экран
    func didNotGetAdress(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Записываем в Label адреса
        self.adressLabel.text = "-/-"
        
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
        }
    }
    
    // Сообщает пользователю информацию о том, что приложение не имеет доступа к геолокации
    func showLocationServicesDeniedAlert() {
        let title = "Нет доступа к геолокации"
        let message = "Пожалуйста, дайте приложению доступ к геолокационным данным."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // Срабатывает в том случае, если не были определены координаты. Выводит информацию об ошибке
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        // Остановили обновление позиции
        locationManager.stopUpdatingLocation()
        // Обновили Label с широтой и долготой
        updateLabels()
        
        // Разблокируем кнопки TabBar
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
        }
    }
    
    // Срабатывает при успешном получении координат
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Запомнили местоположение
        location = locations[0]
        // Закончили обновление координат
        locationManager.stopUpdatingLocation()
        
        // Отображаем изменения на экране
        updateLabels()
        
        // Получает погоду по широте и долготе
        self.weather.getWeather(latitude: String(format: "%.3f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.3f", (self.location?.coordinate.longitude)!))
        // Получает адрес по широте и долготе
        self.reverseGeocoder.getAdress(latitude: String(format: "%.5f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.5f", (self.location?.coordinate.longitude)!))
        
    }
    

}


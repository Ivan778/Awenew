//
//  FirstViewController.swift
//  NibleSoft
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import CoreLocation

class FirstViewController: UIViewController, CLLocationManagerDelegate, WeatherReceiverDelegate, GoogleGeocoderDelegate {
    // Ссылка на Label, который будет отображать широту
    @IBOutlet weak var latitudeLabel: UILabel!
    // Ссылка на Label, который будет отображать страну
    @IBOutlet weak var countryLabel: UILabel!
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
    //
    var updatingLocation = false
    //
    var lastLocationError: Error?
    
    // Для получения погоды
    var weather: WeatherReceiver!
    // Для получения адреса
    var reverseGeocoder: GoogleGeocoder!
    
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
        
        blockBarButtons()
        
        weather = WeatherReceiver(delegate: self)
        reverseGeocoder = GoogleGeocoder(delegate: self)
        
        latitudeLabel.text = ""
        countryLabel.text = ""
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
            latitudeLabel.text = String("")
        }
    }
    
    // Принимает данные о погоде и выводит их на экран
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            self.temperatureAndDescriptionLabel.text = "\(weather.temperature) °C"
            self.humidityLabel.text = "\(weather.humidity) %"
            self.pressureLabel.text = "\(weather.pressure) мм рт. ст."
            self.weatherIconImageView.image = UIImage(named: weather.icon)
        }
    }
    
    // Принимает данные об ошибке, из-за которой не была определена погода, и выводит её на экран
    func didNotGetWeather(error: NSError) {
        DispatchQueue.main.async {
            self.temperatureAndDescriptionLabel.text = "-/-"
            self.humidityLabel.text = "-/-"
            self.pressureLabel.text = "-/-"
        }
    }
    
    // Принимает адрес и выводит его на экран
    func didGetAdress(adress: String) {
        DispatchQueue.main.async {
            self.countryLabel.text = adress
            
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
            currentItem["Adress"] = adress
            // Записываем широту
            currentItem["Latitude"] = String(format: "%.7f", (self.location?.coordinate.latitude)!)
            // Записываем долготу
            currentItem["Longitude"] = String(format: "%.7f", (self.location?.coordinate.longitude)!)
            
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
            
        }
    }
    
    // Принимает данные об ошибке, из-за которой не был определён адрес, и выводит её на экран
    func didNotGetAdress(error: NSError) {
        DispatchQueue.main.async {
            self.countryLabel.text = "-/-"
            
            let tabBarControllerItems = self.tabBarController?.tabBar.items
            
            if let tabArray = tabBarControllerItems {
                let tabBarItem1 = tabArray[0]
                let tabBarItem2 = tabArray[1]
                
                tabBarItem1.isEnabled = true
                tabBarItem2.isEnabled = true
            }
        }
    }
    
    // Сообщает пользователю информацию о том, что приложение не имеет доступа к геолокации
    func showLocationServicesDeniedAlert() {
        let title = "Нет доступа к геолокации"
        let message = "Пожалуйста, дайте приложению доступ к геолокационным данным."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // Срабатывает в том случае, если не были определены координаты. Выводит информацию об ошибке
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        // Записали ошибку
        lastLocationError = error
        // Остановили обновление позиции
        locationManager.stopUpdatingLocation()
        // Обновили Label с широтой и долготой
        updateLabels()
    }
    
    // Срабатывает при успешном получении координат
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Запомнили местоположение
        location = locations[0]
        // Закончили обновление координат
        locationManager.stopUpdatingLocation()
        
        lastLocationError = nil
        updateLabels()
        
        // Получает погоду по широте и долготе
        self.weather.getWeather(latitude: String(format: "%.3f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.3f", (self.location?.coordinate.longitude)!))
        // Получает адрес по широте и долготе
        self.reverseGeocoder.getAdress(latitude: String(format: "%.5f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.5f", (self.location?.coordinate.longitude)!))
        
    }
    

}


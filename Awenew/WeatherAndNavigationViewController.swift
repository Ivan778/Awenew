//
//  WeatherAndNavigationViewController.swift
//  Awenew
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherAndNavigationViewController: UIViewController, CLLocationManagerDelegate, WeatherReceiverDelegate, GoogleGeocoderDelegate {
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var temperatureAndDescriptionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    // Нужно для локации
    let locationManager = CLLocationManager()
    // Будет хранить координаты
    var location: CLLocation?
    
    var gotLocation = false
    
    var wroteWeather = false
    var wroteLocation = false
    
    var gotWeather = false
    var gotAddress = false
    
    // Для получения погоды
    var weather: WeatherReceiver!
    // Для получения адреса
    var reverseGeocoder: GoogleGeocoder!
    
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Блокируем кнопки TabBar, чтобы пользователь не мог перейти, когда осуществляется подгрузка данных о погоде
        lockUnlockBarButtons(value: false)
        
        // Для протоколов
        weather = WeatherReceiver(delegate: self)
        reverseGeocoder = GoogleGeocoder(delegate: self)
        
        // Инициализируем LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        group.notify(queue: DispatchQueue.main) {
            self.lockUnlockBarButtons(value: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Reachability notification
    func updateUserInterface() {
        if ((!gotWeather || !gotAddress || !gotLocation) && (Network.reachability?.isReachable)!) {
            //lockUnlockBarButtons(value: false)
            locationManager.startUpdatingLocation()
        }
    }
    
    func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // MARK: - View update methods
    func showLocationServicesDeniedAlert() {
        let title = "Нет доступа к геолокации"
        let message = "Пожалуйста, дайте приложению доступ к геолокационным данным."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func lockUnlockBarButtons(value: Bool) {
        DispatchQueue.main.async {
            let tabBarControllerItems = self.tabBarController?.tabBar.items
            
            if let tabArray = tabBarControllerItems {
                let tabBarItem1 = tabArray[0]
                let tabBarItem2 = tabArray[1]
                let tabBarItem3 = tabArray[2]
                let tabBarItem4 = tabArray[3]
                
                tabBarItem1.isEnabled = value
                tabBarItem2.isEnabled = value
                tabBarItem3.isEnabled = value
                tabBarItem4.isEnabled = value
            }
        }
    }
    
    func updateLabels() {
        if let loc = location {
            latitudeLabel.text = String(format: "%.7f", loc.coordinate.latitude) + ", " + String(format: "%.7f", loc.coordinate.longitude)
        } else {
            latitudeLabel.text = String("-/-, -/-")
        }
    }
    
    // MARK: - WeatherReceiver delegate methods
    func didGetWeather(weather: Weather) {
        gotWeather = true
        DispatchQueue.global(qos: .userInitiated).async {
            if self.wroteWeather == false {
                DispatchQueue.main.async {
                    // Записываем данные о погоде в их Label-ы
                    self.temperatureAndDescriptionLabel.text = "\(weather.temperature) °C"
                    self.humidityLabel.text = "\(weather.humidity) %"
                    self.pressureLabel.text = "\(weather.pressure) мм рт. ст."
                    self.weatherIconImageView.image = UIImage(named: weather.icon)
                }
                
                // Записываем погоду в файл
                WriteWeatherToFile.write(weather: weather)
                
                self.group.leave()
                
                // Говорим, что уже была осуществлена запись погоды в файл
                self.wroteWeather = true
            }
            
        }
    }
    
    func didNotGetWeather(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Отображаем изменения на экране
        self.temperatureAndDescriptionLabel.text = "-/-"
        self.humidityLabel.text = "-/-"
        self.pressureLabel.text = "-/-"
        
        self.group.leave()
    }
    
    // MARK: - GoogleGeocoder delegate methods
    func didGetAdress(adress: [String]) {
        gotAddress = true
        DispatchQueue.global(qos: .userInitiated).async {
            if self.wroteLocation == false {
                DispatchQueue.main.async {
                    // Отображаем адрес на экран
                    self.adressLabel.text = adress[0]
                }
                
                // Пишем адрес в файл
                WriteAdressToFile.write(adress: adress, latitude: (self.location?.coordinate.latitude)!, longitude: (self.location?.coordinate.longitude)!)
                
                self.group.leave()
                
                self.wroteLocation = true
            }
            
        }
    }
    
    func didNotGetAdress(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Записываем в Label адреса
        self.adressLabel.text = "-/-"
        
        self.group.leave()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        // Остановили обновление позиции
        locationManager.stopUpdatingLocation()
        // Обновили Label с широтой и долготой
        updateLabels()
        
        lockUnlockBarButtons(value: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Запомнили местоположение
        location = locations[0]
        // Закончили обновление координат
        locationManager.stopUpdatingLocation()
        
        // Отображаем изменения на экране
        updateLabels()
        
        if Reachability.isConnectedToNetworkNow() {
            // Получает погоду по широте и долготе
            self.weather.getWeather(latitude: String(format: "%.3f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.3f", (self.location?.coordinate.longitude)!))
            self.group.enter()
            // Получает адрес по широте и долготе
            self.reverseGeocoder.getAddress(latitude: String(format: "%.5f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.5f", (self.location?.coordinate.longitude)!))
            self.group.enter()
            
            self.gotLocation = true
        }
    }
}

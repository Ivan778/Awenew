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
    
    let group = DispatchGroup()
    
    // Блокирует/разблокирует кнопки TabBar
    func lockUnlockBarButtons(value: Bool) {
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            
            tabBarItem1.isEnabled = value
            tabBarItem2.isEnabled = value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Блокируем кнопки TabBar, чтобы пользователь не мог перейти, когда осуществляется подгрузка данных о погоде
        lockUnlockBarButtons(value: false)
        
        //FileProcessor.saveChecklistItems(items: [[String: String]](), key: "PreviousRequests")
        //FileProcessor.saveChecklistItems(items: [[String: String]](), key: "PreviousWeatherRequests")
        
        // Для протоколов
        weather = WeatherReceiver(delegate: self)
        reverseGeocoder = GoogleGeocoder(delegate: self)
        
        // Инициализируем LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Считываем значение часа
        let currentHours = NSCalendar.current.component(.hour, from: Date())
        // Если сейчас тёмное время суток, то делаем фон тёмно-синим
        if (currentHours > 20 || currentHours < 5) {
            self.view.backgroundColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 112.0/255.0, alpha: 1)
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.lockUnlockBarButtons(value: true)
        }
        
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
    
    // Принимает данные об ошибке, из-за которой не была определена погода, и выводит её на экран
    func didNotGetWeather(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Отображаем изменения на экране
        self.temperatureAndDescriptionLabel.text = "-/-"
        self.humidityLabel.text = "-/-"
        self.pressureLabel.text = "-/-"
        
        self.group.leave()
    }
    
    // Принимает адрес и выводит его на экран
    func didGetAdress(adress: [String]) {
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
    
    // Принимает данные об ошибке, из-за которой не был определён адрес, и выводит её на экран
    func didNotGetAdress(error: NSError) {
        // Выводим причину ошибки
        print(error)
        
        // Записываем в Label адреса
        self.adressLabel.text = "-/-"
        
        group.leave()
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
        group.enter()
        // Получает адрес по широте и долготе
        self.reverseGeocoder.getAdress(latitude: String(format: "%.5f", (self.location?.coordinate.latitude)!), longitude: String(format: "%.5f", (self.location?.coordinate.longitude)!))
        group.enter()
    }

}

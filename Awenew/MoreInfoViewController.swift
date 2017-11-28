//
//  MoreInfoViewController.swift
//  Awenew
//
//  Created by Иван on 03.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import Foundation

class MoreInfoViewController: UIViewController {
    // Ссылка на ImageView с картинкой погоды
    @IBOutlet weak var weatherIconImageView: UIImageView!
    // Ссылка на Label с температурой
    @IBOutlet weak var temperatureLabel: UILabel!
    // Ссылка на Label с влажностью
    @IBOutlet weak var humidityLabel: UILabel!
    // Ссылка на Label с давтлением
    @IBOutlet weak var pressureLabel: UILabel!
    // Ссылка на Label с адресом
    @IBOutlet weak var adressLabel: UILabel!
    // Ссылка на Label с координатами (широта, долгота)
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    var numberOfItemToShow: Int?
    
    var weatherInfo: Weather?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // То погружаем из файла информацию о его местоположении
        let location = FileProcessor.loadChecklistItems(key: "PreviousRequests")
        
        if (location.count > numberOfItemToShow!) {
            self.coordinatesLabel.text = "\(location[numberOfItemToShow!]["Latitude"]!), \(location[numberOfItemToShow!]["Longitude"]!)"
            self.adressLabel.text = location[numberOfItemToShow!]["Adress"]!
            
            // Подгружаем информацию о погоде
            let weather = FileProcessor.loadChecklistItems(key: "PreviousWeatherRequests")
            self.weatherIconImageView.image = UIImage(named: weather[numberOfItemToShow!]["Icon"]!)
            self.temperatureLabel.text = weather[numberOfItemToShow!]["Temperature"]!
            self.humidityLabel.text = weather[numberOfItemToShow!]["Humidity"]!
            self.pressureLabel.text = weather[numberOfItemToShow!]["Pressure"]!
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "SawIt") == false {
            let title = "Приветствую Вас"
            let message = "Для того, чтобы перейти назад, просто прикоснитесь к любому месту на экране."
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "SawIt")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

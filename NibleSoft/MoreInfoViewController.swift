//
//  MoreInfoViewController.swift
//  NibleSoft
//
//  Created by Иван on 03.05.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Если к нам пришёл элемент, который надо показать
        if let number = numberOfItemToShow {
            // То погружаем из файла информацию о его местоположении
            let location = FileProcessor.loadChecklistItems(key: "PreviousRequests")
            self.coordinatesLabel.text = "\(location[number]["Latitude"]!), \(location[number]["Longitude"]!)"
            self.adressLabel.text = location[number]["Adress"]!
            
            // Подгружаем информацию о погоде
            let weather = FileProcessor.loadChecklistItems(key: "PreviousWeatherRequests")
            self.weatherIconImageView.image = UIImage(named: weather[number]["Icon"]!)
            self.temperatureLabel.text = weather[number]["Temperature"]!
            self.humidityLabel.text = weather[number]["Humidity"]!
            self.pressureLabel.text = weather[number]["Pressure"]!
            
            let currentHours = Int(location[number]["Hours"]!)!
            
            if (currentHours > 20 || currentHours < 5) {
                self.view.backgroundColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 112.0/255.0, alpha: 1)
            }
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Если пользователь прикоснулся к экрану
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // То переходим на предыдущий ViewController
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

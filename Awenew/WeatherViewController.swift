//
//  WeatherViewController.swift
//  Awenew
//
//  Created by Иван on 27.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

class WeatherViewController: UIViewController, UITableViewDataSource, WeatherReceiverDelegate {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var weather: Weather?
    var address: String?
    var coordinates: [String]?
    
    var forecast: WeatherReceiver!
    var forecastList = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        self.weatherIcon.image = UIImage(named: (weather?.icon)!)
        self.temperatureLabel.text = String("\((weather?.temperature)!) °C")
        self.humidityLabel.text = String("\((weather?.humidity)!) %")
        self.pressureLabel.text = String("\((weather?.pressure)!) мм рт. ст.")
        self.addressLabel.text = address
        
        forecast = WeatherReceiver(delegate: self)
        forecast.getForecast(coordinates: coordinates!)
        activityIndicator.isHidden = false
    }
    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        let icon = cell.viewWithTag(721) as! UIImageView
        icon.image = UIImage(named: forecastList[indexPath.row].icon)
        
        let date = cell.viewWithTag(722) as! UILabel
        date.text = forecastList[indexPath.row].descr
        
        let temperature = cell.viewWithTag(723) as! UILabel
        temperature.text = String("\(forecastList[indexPath.row].temperature) °C")
        
        let moreInfo = cell.viewWithTag(724) as! UILabel
        moreInfo.text = String("\(forecastList[indexPath.row].humidity) %, \(forecastList[indexPath.row].pressure)  мм рт. ст.")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    // MARK: - WeatherReceiver delegate methods
    func didGetForecast(forecast: [Weather]) {
        forecastList = forecast
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.isHidden = true
        }
    }
    
    func didNotGetForecast(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.presentAlert(title: "Ошибка!", message: "Данные о прогнозе погоды не были загружены!")
        }
    }
    
    // MARK: - Gesture methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

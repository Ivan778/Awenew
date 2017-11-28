//
//  WeatherSearchViewController.swift
//  Awenew
//
//  Created by Иван on 26.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import Foundation

class WeatherSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, PlacesIDsDelegate, GoogleGeocoderDelegate, WeatherReceiverDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchItems = [String: String]()
    
    var placesReceiver: PlacesIDs!
    var coordinatesReceiver: GoogleGeocoder!
    var weatherReceiver: WeatherReceiver!
    
    var selectedItemNumber = Int()
    var coordinates = [String]()
    var weatherToShow: Weather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDoneOnKeyboard()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        placesReceiver = PlacesIDs(delegate: self)
        coordinatesReceiver = GoogleGeocoder(delegate: self)
        weatherReceiver = WeatherReceiver(delegate: self)
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.searchBar.inputAccessoryView = keyboardToolbar
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Если сейчас осуществится переход по какому-либо segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWeather" {
            
            let controller = segue.destination as! WeatherViewController
            
            controller.weather = weatherToShow
            controller.address = Array(searchItems.keys)[selectedItemNumber]
            controller.coordinates = coordinates
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if Reachability.isConnectedToNetwork() {
            self.placesReceiver.getListOfItems(searchPhrase: searchBar.text!)
            self.activityIndicator.isHidden = false
        } else {
            self.presentAlert(title: "Ошибка!", message: "Проверьте Ваше соединение с интернетом.")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchItems.removeAll()
            tableView.reloadData()
        }
    }
    
    // MARK: - TableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath)
        
        let searchItemLabel = cell.viewWithTag(521) as! UILabel
        searchItemLabel.text = Array(searchItems.keys)[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        if Reachability.isConnectedToNetwork() {
            self.activityIndicator.isHidden = false
            self.selectedItemNumber = indexPath.row
            self.coordinatesReceiver.getCoordinatesByID(ID: Array(self.searchItems.values)[indexPath.row])
        } else {
            self.presentAlert(title: "Ошибка!", message: "Проверьте Ваше соединение с интернетом.")
        }
    }
    
    // MARK: - PlaceGeocoordinates delegate methods
    func didGetList(items: [String : String]) {
        searchItems = items
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
            self.activityIndicator.isHidden = true
        }
    }
    
    func didNotGetList(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.presentAlert(title: "Ошибка!", message: "Данные не были получены.")
        }
    }
    
    // MARK: - GoogleGeocoder delegate methods
    func didGetCoordinates(coordinates: [String]) {
        self.coordinates = coordinates
        weatherReceiver.getWeather(latitude: coordinates[0], longitude: coordinates[1])
    }
    
    func didNotGetCoordinates(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.presentAlert(title: "Ошибка!", message: "Данные не были получены.")
        }
    }
    
    // MARK: - WeatherReceiver delegate methods
    func didGetWeather(weather: Weather) {
        weatherToShow = weather
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.performSegue(withIdentifier: "ShowWeather", sender: self)
        }
    }
    
    func didNotGetWeather(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.presentAlert(title: "Ошибка!", message: "Данные не были получены.")
        }
    }
}

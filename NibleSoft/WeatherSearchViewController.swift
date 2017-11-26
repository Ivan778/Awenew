//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Иван on 26.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import Foundation
 
class WeatherSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, PlacesIDsDelegate, GoogleGeocoderDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchItems = [String: String]()
    
    var placeCoordinates: PlacesIDs!
    var geocoder: GoogleGeocoder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        placeCoordinates = PlacesIDs(delegate: self)
        geocoder = GoogleGeocoder(delegate: self)
    }
    
    // MARK: - SearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if Reachability.isConnectedToNetwork() {
            placeCoordinates.getListOfItems(searchPhrase: searchBar.text!)
            activityIndicator.isHidden = false
        } else {
            let alert = UIAlertController(title: "Ошибка соединения", message: "Проверьте Ваше соединение с интернетом.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
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
    
    // MARK: - PlaceGeocoordinates delegate methods
    func didGetList(items: [String : String]) {
        searchItems = items
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
            self.activityIndicator.isHidden = true
        }
        
        print("Hello")
    }
    
    func didNotGetList(error: NSError) {
        activityIndicator.isHidden = true
    }
    
    // MARK: - GoogleGeocoder delegate methods
    func didGetCoordinates(coordinates: [String]) {
        print(coordinates)
    }
    
    func didNotGetCoordinates(error: NSError) {
        
    }
}

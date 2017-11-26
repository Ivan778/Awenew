//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Иван on 26.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import Foundation

class WeatherSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchItems = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    // MARK: - SearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - TableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath)
        
        let searchItemLabel = cell.viewWithTag(521) as! UILabel
        searchItemLabel.text = (searchItems[indexPath.row]["Name"])!
        
        return cell
    }
}

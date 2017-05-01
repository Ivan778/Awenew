//
//  SecondViewController.swift
//  NibleSoft
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableWithHistory: UITableView!
    
    // Массив словарей с предыдущими запросами
    var allItems = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allItems = FileProcessor.loadChecklistItems()
        
        tableWithHistory.delegate = self
        tableWithHistory.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allItems.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableWithHistory.dequeueReusableCell(withIdentifier: "RequestItem", for: indexPath)
        
        let row = indexPath.row
        
        let dateLabel = cell.viewWithTag(1000) as! UILabel
        dateLabel.text = (allItems[row]["Date"])!
        
        let locationLabel = cell.viewWithTag(1001) as! UILabel
        locationLabel.text = "\((allItems[row]["Latitude"])!), \((allItems[row]["Longitude"])!)"
        
        return cell
    }

}


//
//  NewsLoaderViewController.swift
//  Awenew
//
//  Created by Иван on 27.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import Kanna

class NewsLoaderViewController: UITableViewController, NewsReceiverDelegate {
    weak var activityIndicator: UIActivityIndicatorView!
    
    var newsReceiver: NewsReceiver!
    var news = [News]()
    var newsNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicator
        self.activityIndicator = activityIndicator
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        newsReceiver = NewsReceiver(delegate: self)
        newsReceiver.getNewsHeadlines(searchString: "Беларусь")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let controller = segue.destination as! NewsViewController
            controller.newsURL = news[newsNumber].reserved
        }
    }

    // MARK: - TableView delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        newsNumber = indexPath.row
        
        self.performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)

        let date = cell.viewWithTag(111) as! UILabel
        date.text = news[indexPath.row].newsName

        return cell
    }
    
    // MARK: - NewsReceiver delegate methods
    func didGetNews(news: [News]) {
        self.news = news
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.isHidden = true
        }
    }
    
    func didNotGetNews(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        }
    }

}

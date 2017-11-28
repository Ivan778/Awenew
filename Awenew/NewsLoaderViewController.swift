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
    var newsReceiver: NewsReceiver!
    var news = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsReceiver = NewsReceiver(delegate: self)
        newsReceiver.getNewsHeadlines(searchString: "Беларусь")
    }
    
    func loaded(html: String) {
        print(html)
    }

    // MARK: - TableView delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        }
    }
    
    func didNotGetNews(error: NSError) {
        
    }

}

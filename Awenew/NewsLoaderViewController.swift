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
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var activityIndicator: UIActivityIndicatorView!
    
    var newsReceiver: NewsReceiver!
    var news = [News]()
    var newsNumber = 0
    
    var gotIt = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        tableView.backgroundView = activityIndicator
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        newsReceiver = NewsReceiver(delegate: self)
        loadNews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
    }
    
    func loadNews() {
        let searchPhrase = UserDefaults.standard.string(forKey: "searchPhrase")
        
        if Reachability.isConnectedToNetworkNow() {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            if (searchPhrase != nil) {
                newsReceiver.getNewsHeadlines(searchString: searchPhrase!)
            } else {
                newsReceiver.getNewsHeadlines(searchString: "новости")
            }
            
        } else {
            presentAlert(title: "Ошибка!", message: "Проверьте соединение с интернетом.")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        loadNews()
    }
    
    // MARK: - Reachability notification
    func statusManager(_ notification: Notification) {
        let searchPhrase = UserDefaults.standard.string(forKey: "searchPhrase")
        
        if (!gotIt && (Network.reachability?.isReachable)!) {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            if (searchPhrase != nil) {
                newsReceiver.getNewsHeadlines(searchString: searchPhrase!)
            } else {
                newsReceiver.getNewsHeadlines(searchString: "новости")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let controller = segue.destination as! NewsViewController
            controller.news = news[newsNumber]
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
        gotIt = true
        
        if news.count == 0 {
            presentAlert(title: "Извините!", message: "По данному региону нет новостей")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didNotGetNews(error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

}

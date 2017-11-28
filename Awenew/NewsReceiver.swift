//
//  NewsReceiver.swift
//  Awenew
//
//  Created by Иван on 28.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

protocol NewsReceiverDelegate {
    func didGetNews(news: [News])
    func didNotGetNews(error: NSError)
}

class NewsReceiver {
    private let baseURL = "https://news.tut.by/search/?str=";
    private var delegate: NewsReceiverDelegate
    
    init(delegate: NewsReceiverDelegate) {
        self.delegate = delegate
    }
    
    func getNewsHeadlines(searchString: String) {
        let url = String("\(baseURL)\(searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")
        
        DispatchQueue.global(qos: .utility).async {
            if let searchURL = URL(string: url!) {
                do {
                    let html = try String(contentsOf: searchURL)
                    self.delegate.didGetNews(news: NewsParser.parseNews(html: html))
                } catch {
                    self.delegate.didNotGetNews(error: NSError(domain: "Не могу загрузить новости (возможно, нет интернета)!", code: 404))
                }
            } else {
                self.delegate.didNotGetNews(error: NSError(domain: "Проверьте правильность ссылки!", code: 404))
            }
        }
    }
}

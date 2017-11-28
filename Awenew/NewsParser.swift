//
//  NewsParser.swift
//  Awenew
//
//  Created by Иван on 28.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation
import Kanna

class NewsParser {
    class func parseNews(html: String) -> [News] {
        var newsList = [News]()
        
        if let doc = HTML(html: html, encoding: .utf8) {
            print("\n\n")
            for link in doc.xpath("//div[@class='results-header']/h3/a") {
                if newsList.count >= 10 { break }
                if let text = link.text {
                    if let url = link["href"] {
                        newsList.append(News(newsName: text, newsURL: url))
                    }
                }
            }
            
            var index = 0
            var minus = 0
            
            for link in doc.xpath("//div[@class='results__content']/ul/li[1]/a") {
                if index >= 9 { break }
                if let date = link.text {
                    if !dateChecker(date: date) {
                        newsList.remove(at: index - minus)
                        minus += 1
                    }
                    index += 1
                }
            }
        }
        
        return newsList
    }
    
    private class func dateChecker(date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy,"
        let myDate = dateFormatter.date(from: date)!
        
        if (Date().timeIntervalSince(myDate) / 60 / 60) <= 72.0 {
            return true
        } else {
            return false
        }
    }
}

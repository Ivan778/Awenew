//
//  News.swift
//  Awenew
//
//  Created by Иван on 28.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

struct News {
    let newsName: String
    let newsURL: String
    
    init(newsName: String, newsURL: String) {
        self.newsName = newsName
        self.newsURL = newsURL
    }
}

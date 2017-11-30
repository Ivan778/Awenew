//
//  NewsViewController.swift
//  Awenew
//
//  Created by Иван on 29.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitleColor()
        
        self.title = (news?.newsName)!
        
        webView.delegate = self
        
        let url = NSURL (string: (news?.reserved)!);
        let request = NSURLRequest(url: url! as URL);
        self.webView.loadRequest(request as URLRequest);
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = true
    }

}

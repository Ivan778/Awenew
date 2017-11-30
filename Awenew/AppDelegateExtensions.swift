//
//  AppDelegateExtensions.swift
//  Awenew
//
//  Created by Иван on 30.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

extension AppDelegate {
    enum Shortcut: String {
        case news = "news"
        case main = "main"
        case weather = "weather"
        case history = "history"
    }
    
    func setInitialViewController(initialViewControllerIndex: Int) {
        let tabBarController = self.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = initialViewControllerIndex
        
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
                case .main: setInitialViewController(initialViewControllerIndex: 0); return true
                case .news: setInitialViewController(initialViewControllerIndex: 1); return true
                case .weather: setInitialViewController(initialViewControllerIndex: 2); return true
                case .history: setInitialViewController(initialViewControllerIndex: 3); return true
            }
        }
        return false
    }
}

extension AppDelegate {
    func reachabilityCheck() {
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
}

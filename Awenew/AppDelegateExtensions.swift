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
        /*
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: initialViewControllerID)
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
 */
        let tabBarController = self.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = initialViewControllerIndex
        
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
                case .main: setInitialViewController(initialViewControllerIndex: 0); quickActionHandled = true; break;
                case .news: setInitialViewController(initialViewControllerIndex: 1); quickActionHandled = true; break;
                case .weather: setInitialViewController(initialViewControllerIndex: 2); quickActionHandled = true; break;
                case .history: setInitialViewController(initialViewControllerIndex: 3); quickActionHandled = true; break;
            }
        }
        return quickActionHandled
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

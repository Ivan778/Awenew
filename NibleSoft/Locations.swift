//
//  Locations.swift
//  NibleSoft
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Locations {
    private let locationManager = CLLocationManager()
    
    public func getLocation(view: UIViewController, locationDelegate: CLLocationManagerDelegate) {
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            showLocationServicesDeniedAlert(view: view)
            return
        }
        
    }
    
    private func showLocationServicesDeniedAlert(view: UIViewController) {
        let title = "Нет доступа к геолокации"
        let message = "Пожалуйста, дайте приложению доступ к геолокационным данным."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        view.present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    
}

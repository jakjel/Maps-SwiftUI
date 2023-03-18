//
//  LocationManager.swift
//
//  Created by Jakub Jelinek on 11/03/2023.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else{
            print("Didn't get location!")
            return
        }
        DispatchQueue.main.async {
            self.location = location
            print(location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location access granted.")
        case .denied, .restricted:
            print("Location access denied.")
        case .notDetermined:
            print("Location status not determined.")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError("New case for CLLocationManagerDelegate?")
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    
    func manager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else{
            print("didnt get location!")
            return
        }
        DispatchQueue.main.async {
            self.location = location
            print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}



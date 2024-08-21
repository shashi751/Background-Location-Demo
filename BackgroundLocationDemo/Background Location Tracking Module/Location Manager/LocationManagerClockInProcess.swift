//
//  LocationManager.swift
//  BackgroundLocationDemo
//
//  Created by Shashi Gupta on 21/08/24.
//

import Foundation
import CoreLocation
import UIKit


class LocationManagerClockInProcess: NSObject {
    
    static let shared = LocationManagerClockInProcess()
    
    private let locationManager = CLLocationManager()
    private var isUpdatingLocation = false
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private let locationLogger : LocationLoggerProtocol // Location logger instance creation
    
    init(locationLogger:LocationLoggerProtocol = LocationLogger()){
        self.locationLogger = locationLogger
        
        super.init()
        configureLocationManager()
    }
    
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Adjust as needed
        locationManager.distanceFilter = 5 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true // Shows blue bar when app uses location in background
    }
    
    func requestLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationUpdates() {
        
        DispatchQueue.global().async {[weak self] in
            
            guard CLLocationManager.locationServicesEnabled(), let isUpdatingLocation =  self?.isUpdatingLocation, let weakSelf = self else { return }
            
            if !(isUpdatingLocation) {
                weakSelf.locationManager.startUpdatingLocation()
                weakSelf.isUpdatingLocation = true
            }
        }
    }
    
    func stopLocationUpdates() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            isUpdatingLocation = false
        }
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "LocationBackgroundTask") {
            self.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    private func sendLocationToServer(_ location: CLLocation) {
        // Start background task to ensure the operation completes even if the app is in background
        startBackgroundTask()
        
        // Prepare your request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            print("TEST:: Location send to server success \(Date().toLocalTimeString())")
            // Log the location
            
            self?.locationLogger.logLocation(location, sentToServer: true)

            self?.endBackgroundTask()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManagerClockInProcess: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
//            startLocationUpdates()
            print("Location access authorizedAlways.")
        case .authorizedWhenInUse:
            // Optionally handle when-in-use authorization
//            startLocationUpdates()
            print("Location access authorizedWhenInUse.")
        case .denied, .restricted:
            // Handle denied access
            print("Location access denied.")
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("New location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        sendLocationToServer(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}

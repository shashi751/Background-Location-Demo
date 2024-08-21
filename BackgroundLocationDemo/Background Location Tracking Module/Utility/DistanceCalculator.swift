//
//  DistanceCalculator.swift
//  BackgroundLocationDemo
//
//  Created by Shashi Gupta on 21/08/24.
//

import Foundation

import CoreLocation
import Foundation

protocol DistanceCalculatorProtocol{
    func getTotalDistanceInKilometers() -> String
}

class DistanceCalculator : DistanceCalculatorProtocol{
    
    var locationLogger: LocationLoggerProtocol
    init(locationLogger:LocationLoggerProtocol = LocationLogger()) {
        self.locationLogger = locationLogger
    }
    
    // Calculate total distance based on locations from the location logger
    private func calculateTotalDistanceFromLoggedLocations() -> Double{
        
        let locations = self.locationLogger.fetchLogs()
        guard locations.count > 1 else { return 0.0 }
        
        var totalDistance: CLLocationDistance = 0.0
        var previousLocation = CLLocation(latitude: locations[0].latitude, longitude: locations[0].longitude)
        
        for location in locations.dropFirst() {
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = loc.distance(from: previousLocation)
            totalDistance += distance
            previousLocation = loc
        }
        
        return totalDistance
    }
    
    // Convert distance from meters to kilometers
    func getTotalDistanceInKilometers() -> String {
        let totalDistanceInMeters = calculateTotalDistanceFromLoggedLocations()
        let km = totalDistanceInMeters / 1000.0
        let formattedKM = String(format: "%.02f", km) + " km"
        return formattedKM
    }
}

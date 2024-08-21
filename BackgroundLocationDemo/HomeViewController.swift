//
//  HomeViewController.swift
//  BackgroundLocationDemo
//
//  Created by Shashi Gupta on 21/08/24.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: - IBOUTLETS
    @IBOutlet weak var btnClockedInOut: UIButton!
    
    //MARK: - VARAIBLES
    let distanceCalculator:DistanceCalculatorProtocol = DistanceCalculator()
    let logger : LocationLoggerProtocol = LocationLogger()
    let locationManager = LocationManagerClockInProcess.shared
    var isClockedIn : Bool = false
    
    //MARK: - OVERRIDDEN METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestLocationPermissions()
        
        self.showLogs()
       
    }

    //MARK: - ACTION METHODS
    @IBOutlet weak var tvLogs: UITextView!
    
    @IBAction func clockIn(_ sender: UIButton) {
        
        if isClockedIn{
            self.locationManager.stopLocationUpdates()
            self.btnClockedInOut.setTitle("Clock In", for: .normal)
            self.btnClockedInOut.setTitleColor(.systemGreen, for: .normal)
        }
        else{
            self.locationManager.startLocationUpdates()
            self.btnClockedInOut.setTitle("Clock Out", for: .normal)
            self.btnClockedInOut.setTitleColor(.systemRed, for: .normal)
        }
        
        self.showLogs()
        self.isClockedIn.toggle()
    }
 
    @IBAction func showLogs(_ sender: UIButton) {
        self.showLogs()
    }
    
    
    //MARK: - PRIVATE FUNCTIONS
    private func showLogs(){
        
        let logs = logger.fetchLogs()
        
        let distance = distanceCalculator.getTotalDistanceInKilometers()
        print("TEST:: Distance \(distance)")
        
        var logfile = "Distance \(distance) \n\n\n"
        for log in logs {
            logfile += "Timestamp: \((log.timestamp ?? Date()).toLocalTimeString()), Latitude: \(log.latitude), Longitude: \(log.longitude), Status: \(log.status ?? "Unknown")\n\n"
        }
        
        self.tvLogs.text = logfile
        
    }
   
    
}


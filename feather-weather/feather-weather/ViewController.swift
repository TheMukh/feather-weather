//
//  ViewController.swift
//  feather-weather
//
//  Created by IO on 23/08/2019.
//  Copyright © 2019 Mukh LTD. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import Alamofire
import Foundation
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var updateLocationInput: UITextField!
    
    
    let owmApiKey = ""
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateLocationInput.delegate = self
        
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize/2), y: (view.frame.height-indicatorSize/2), width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(owmApiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
//                Add Later Once Image Location has been determined
//                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.weatherLabel.text = jsonWeather["main"].stringValue
                self.tempLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MMM/yyyy"
                self.dateLabel.text = dateFormatter.string(from: date)
                var hour = String(calendar.component(.hour, from:date))
                let minutes = calendar.component(.minute, from: date)
                if (hour == "0") {
                    hour = "00"
                }
                self.timeLabel.text = "\(hour):\(minutes)"
            }
        }
    }
    @IBAction func plusButton(_ sender: Any) {
        locationLabel.text = updateLocationInput.text
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ updateLocationInput: UITextField) -> Bool {
        updateLocationInput.resignFirstResponder()
        return true
    }
}

//
//  ViewController.swift
//  StoryBoardTest
//
//  Created by James Philip Clay on 4/22/21.
//

import UIKit
import Alamofire
import SwiftyJSON

var latitude = String()
var longitude = String()
var latLonString = String()
var forecastUrl = String()
var sunrise = String()
var sunset = String()
var forecastDaysArray = [JSON()]

func UTCtoLocal(UTCDateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    let UTCDate = dateFormatter.date(from: UTCDateString)
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    let UTCToCurrentFormat = dateFormatter.string(from: UTCDate!)
    return UTCToCurrentFormat
}//func

func getCoords(zip: String) {
    let url = "https://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsed_V04_01.aspx?apiKey=b6bbac79af964d3a8630e09c40198d28&version=4.01&zip=\(zip)&format=json"
    AF.request(url).responseJSON { response in
        let json = JSON(response.data as Any)
        let arrayData = json["OutputGeocodes"].arrayValue
        latitude = arrayData[0]["OutputGeocode"]["Latitude"].stringValue
        longitude = arrayData[0]["OutputGeocode"]["Longitude"].stringValue
        latLonString = "\(latitude),\(longitude)"
    }//AF.request
    getPoints(latLonString: latLonString)
    getSunriseSunset(lat: latitude, lon: longitude)
}//func

func getPoints(latLonString: String) {
    let url = "https://api.weather.gov/points/\(latLonString)"
    AF.request(url).responseJSON { response in
        let json = JSON(response.data as Any)
        forecastUrl = json["properties"]["forecast"].stringValue
    }//AF.request
    getForecast(url: forecastUrl)
}//getPoints

func getForecast(url: String) {
    AF.request(url).responseJSON { response in
        let json = JSON(response.data as Any)
        forecastDaysArray =  json["properties"]["periods"].arrayValue
        //print(arrayPeriods[0]["detailedForecast"].stringValue)
        //for item in forecastDaysArray {
        //    print(item["name"].stringValue)
        //    print(item["detailedForecast"].stringValue)
        //}//for
    }//AF.request
}//func

func getSunriseSunset(lat: String, lon: String) {
    let url = "https://api.sunrise-sunset.org/json?lat=\(lat)&lng=\(lon)"
    AF.request(url).responseJSON { response in
        let json = JSON(response.data as Any)
        sunrise = json["results"]["sunrise"].stringValue
        sunset = json["results"]["sunset"].stringValue
    }//AF.request
    //print("sunrise: \(sunrise), sunset: \(sunset)")
}//func

class ViewController: UIViewController {

    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var testTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }//override
    
    @IBAction func calendarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToTableView", sender: self)
    }//@IBAction
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTableView" {
            guard let vc = segue.destination as? UITableViewController else { return }
            vc.tableView.dequeueReusableCell(withIdentifier: "basicStyleCell")?.textLabel?.text = "Test"
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let zipEntry = testTextField.text
        if zipEntry != "" {
            getCoords(zip: "\(zipEntry ?? "")")
            if sunset == "" {
                testLabel.text = "Connection Error, Please Try Again"
            }//if
            else {
                if forecastDaysArray.count > 0 {
                    testLabel.text = "sunrise: \(sunrise) \nsunset: \(sunset) \nforecast: \(forecastDaysArray[0]["detailedForecast"].stringValue)"
                    let firstSpace = sunrise.firstIndex(of: " ") ?? sunrise.endIndex
                    let formattedSunrise = "\(sunrise[..<firstSpace])"
                    print(formattedSunrise)
                }//if
            }//else
        }//if
    }//@IBAction
}//class

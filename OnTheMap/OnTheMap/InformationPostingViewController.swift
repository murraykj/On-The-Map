//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/29/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
  
  // create outlets for each user control
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var viewStudyLocation: UIView!
  @IBOutlet weak var labelStudyLocation: UILabel!
  @IBOutlet weak var buttonFindOnTheMap: UIButton!
  @IBOutlet weak var textboxStudyLocation: UITextField!
  
  @IBOutlet weak var textboxURL: UITextField!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var buttonSubmit: UIButton!

  // set radius of map view to be displayed
  let regionRadius: CLLocationDistance = 4000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Hide controls used to display location and capture URL; show activity indicator
    textboxURL.hidden = true
    mapView.hidden = true
    buttonSubmit.hidden = true
    
    activityIndicator.hidden = true

    mapView.delegate = self
  }
  
  // This function allows teh user to submit a location string
  @IBAction func buttonClickFindOnTheMap(sender:  AnyObject) {
    
    // Hide study location controls and activity indictor
    labelStudyLocation.hidden = true
    textboxStudyLocation.hidden = true
    buttonFindOnTheMap.hidden = true
    
//    activityIndicator.hidden = false

    // check to see if user entered any location data
    if textboxStudyLocation.text.isEmpty {
      // display error if location is empty
      displayAlertMessage("Error", message: "Please enter a location.")
      
      // reset user controls
      textboxURL.hidden = true
      mapView.hidden = true
      buttonSubmit.hidden = true
      
      labelStudyLocation.hidden = false
      textboxStudyLocation.hidden = false
      buttonFindOnTheMap.hidden = false
      
//      self.activityIndicator.hidden = true
      
    } else {
      
      // start the activity indicator
      self.activityIndicator.hidden = false
      
      // save location data
      OTMClient.sharedInstance().studentLocation = textboxStudyLocation.text
      println("Your location is \(OTMClient.sharedInstance().studentLocation!)")
      
      // Get geocode (lat and long)
      var geocoder = CLGeocoder()
      var address = OTMClient.sharedInstance().studentLocation
      
      // convert location string to geocode
      geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
        
        if let placemark = placemarks?[0] as? CLPlacemark {
          
          // save lat and long for posting
          OTMClient.sharedInstance().studentLatitude = placemark.location.coordinate.latitude as Double
          OTMClient.sharedInstance().studentLongitude = placemark.location.coordinate.longitude as Double
          
          println("Latitude \(placemark.location.coordinate.latitude)")
          println("Longitude: \(placemark.location.coordinate.longitude)")
          
          dispatch_async(dispatch_get_main_queue()) {
            
            // add pin with new location to the map
            self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            
            // zoom in on map (set initial coordiantes, call function to center and zoom)
            let initialLocation = CLLocation(latitude: OTMClient.sharedInstance().studentLatitude!, longitude: OTMClient.sharedInstance().studentLongitude!)

            self.centerMapOnLocation(initialLocation)
            
            // insert code to display new view and hide activity indicator
            self.textboxURL.hidden = false
            self.mapView.hidden = false
            self.buttonSubmit.hidden = false
            
            self.activityIndicator.hidden = true
          }
   
        } else {
          // stop activity indicator if geocode cannot be determined
          self.activityIndicator.hidden = true
          
          // ...and display error to the user
          println("Error message: \(error.localizedDescription)")
          self.displayAlertMessage("Location Error", message: "Could not determine your location.")

          // reset url controls
          self.textboxURL.hidden = true
          self.mapView.hidden = true
          self.buttonSubmit.hidden = true
          
          // hide location controls and activity indicator
          self.labelStudyLocation.hidden = false
          self.textboxStudyLocation.hidden = false
          self.buttonFindOnTheMap.hidden = false
          
          self.textboxStudyLocation.text = OTMClient.sharedInstance().studentLocation
        }
      })
    }
  }
  
  // This function allows the application to zoom in on the map
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  
  // This function allows the user to submit a URL
  @IBAction func buttonClickSubmit(sender: UIButton) {
    
    // check to see if user entered a URL
    
    if self.textboxURL.text.isEmpty {
      
      // display error if location is empty
      self.displayAlertMessage("Error", message: "Please enter a valid URL.")
      
      // reset user controls on the view
      // show url controls
      textboxURL.hidden = false
      mapView.hidden = false
      buttonSubmit.hidden = false
      
      // hide location controls
      labelStudyLocation.hidden = true
      textboxStudyLocation.hidden = true
      buttonFindOnTheMap.hidden = true
      
    } else {
      // save User's URL
      OTMClient.sharedInstance().studentURL = textboxURL.text
      
      // using the user's Udacity account number......
      println("Your account # is \(OTMClient.sharedInstance().udacityAccountID!)")
      
      //......get user info before posting URL
      OTMClient.sharedInstance().getUdacityUserData(){
        success, errorCode, errorText in
  
        if (success == true) && (errorCode == nil) {
          OTMClient.sharedInstance().postStudentLocation(){
            success, errorCode, errorText in
            
            if (success == true) && (errorCode == nil) {
              // dismiss view controller and return to tabbed/map view
              self.dismissViewControllerAnimated(true, completion: nil)
              
            }else {
              
              // If user name cannot be obtained, print error and display alert to the user
              println("Error:  \(errorCode!) - \(errorText!)")
              dispatch_async(dispatch_get_main_queue()) {
                
                // Set alert title and text
                let alertTitle = errorCode
                let alertMessage = errorText
                
                // Display alert message
                self.displayAlertMessage(alertTitle!, message: alertMessage!)
              }
            }
          }
        }else {
  
          // If user name cannot be obtained, print error and display alert to the user
          println("Error:  \(errorCode!) - \(errorText!)")
          dispatch_async(dispatch_get_main_queue()) {
  
            // Set alert title and text
            let alertTitle = errorCode
            let alertMessage = errorText
  
            // Display alert message
            self.displayAlertMessage(alertTitle!, message: alertMessage!)
          }
        }
      }
    }
  }

  // This function cancels the current activity and returns the user to the tabbed view
  @IBAction func buttonCancel(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  // Generic function to display alert messages to users
  func displayAlertMessage(title: String, message: String) {
    dispatch_async(dispatch_get_main_queue(), {    let controller = UIAlertController()
      
      // set alert title and message using data passed to function
      controller.title = title
      controller.message = message
      
      let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)
      
      // add buttons and display message
      controller.addAction(okAction)
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
  
}

//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kevin Murray on 7/25/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  // The map. See the setup in the Storyboard file. Note particularly that the view controller
  // is set up as the map view's delegate.
  @IBOutlet weak var mapView: MKMapView!
  
  var studentsInformation: [StudentInformation] = [StudentInformation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create and set the left LOGOUT button
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonTouchUp")
    
    // Create and set the right PIN and REFRESH buttons
    let barButtonPin = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTouchUp")
    let barButtonRefresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")
    self.navigationItem.rightBarButtonItems = [barButtonRefresh, barButtonPin]
    
    // set mapView delegate
    mapView.delegate = self
    
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // call refresh function to retreive data and store data in the studentsInformation array (of structs)
    refreshButtonTouchUp()

  }
  
  
  // Here we create a view with a "right callout accessory view". You might choose to look into other
  // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
  // method in TableViewDataSource.
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinColor = .Red
      pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
    }
    else {
      pinView!.annotation = annotation
    }
    
    return pinView
  }
  
  
  // This delegate method is implemented to respond to taps. It opens the system browser
  // to the URL specified in the annotationViews subtitle property.
  func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == annotationView.rightCalloutAccessoryView {
      let app = UIApplication.sharedApplication()
      app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
    }
  }
  
  // Function used to log user out of Udacity sesion and return then to teh login viewcontroller
  func logoutButtonTouchUp() {
    
    // call function to delete Udacity session
    OTMClient.sharedInstance().deleteUdacitySession(){
      success, errorCode, errorText in
      
      // if successful, return user to login view controller
      if (success == true) && (errorCode == nil) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
      }else {
        
        // otherwise....print error and display alert to the user
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
  
  // Allow user to transition to view to post their pin
  func pinButtonTouchUp() {
    performSegueWithIdentifier("MapViewToInformationPostingView", sender: nil)
  }
  
  
  // Function to refresh current viewcontroller; called by viewWillAppear  
  func refreshButtonTouchUp() {
    
    // call function to retreive data and store data in the studentsInformation array (of structs)
    OTMClient.sharedInstance().retreiveStudentInformation() {
      studentsInformation, errorCode, errorText in
      
      // check to see if data has been retreived
      if let studentsInformation = studentsInformation {
        self.studentsInformation = studentsInformation
        
        dispatch_async(dispatch_get_main_queue()) {
          
          // We will create an MKPointAnnotation for each dictionary in "locations". The
          // point annotations will be stored in this array, and then provided to the map view.
          var annotations = [MKPointAnnotation]()
          
          // The "locations" array is loaded with the sample data below. We are using the dictionaries
          // to create map annotations. This would be more stylish if the dictionaries were being
          // used to create custom structs. Perhaps StudentLocation structs.
          
          for dictionary in studentsInformation {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
          }
          
          // When the array is complete, we add the annotations to the map.
          self.mapView.addAnnotations(annotations)
          
        }
      } else {
        
        // If no data, print error and display alert to the user
        println("Error:  \(errorCode!) - \(errorText!)")
        
        dispatch_async(dispatch_get_main_queue()) {
          
          // Display alert message
          self.displayAlertMessage(errorCode!, message: errorText!)
        }
      }
    }
    
    return
  }
  
}

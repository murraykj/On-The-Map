//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kevin Murray on 7/25/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

  @IBOutlet weak var studentInformationTableView: UITableView!
  
  var studentsInformation: [StudentInformation] = [StudentInformation]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create and set the left LOGOUT button
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonTouchUp")
    
    // Create and set the right PIN and REFRESH buttons
    let barButtonPin = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTouchUp")
    let barButtonRefresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")
    self.navigationItem.rightBarButtonItems = [barButtonRefresh, barButtonPin]
    
  }

  // Retreive data before View appears
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // call refresh function to retreive data and store data in the studentsInforamtion array (of structs)
    refreshButtonTouchUp()
    
  }
  
  
  // Determine number of rows in array....it should be 100
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return studentsInformation.count
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    /* Get cell type */
    let cellReuseIdentifier = "StudentNameCell"
    let studentInformation = studentsInformation[indexPath.row]
    var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
    
    // display pin image next to each entry
    let image = UIImage(named: "pin")
    cell.imageView?.image = image
    
    /* Set cell defaults */
    cell.textLabel!.text = studentInformation.firstName + " " + studentInformation.lastName
    
    return cell
  }
  
  // determine which row selected and then open browser session to display user's url
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // get user url
    var studentURL = studentsInformation[indexPath.row].mediaURL
    
    // open browser
    UIApplication.sharedApplication().openURL(NSURL(string:studentURL)!)

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
          
          // Display alert message
          self.displayAlertMessage(errorCode!, message: errorText!)
        }
      }
    }
  }
  
  
  func pinButtonTouchUp() {
    performSegueWithIdentifier("TableViewToInformationPostingView", sender: nil)
  }
  
  
  // Function to refresh current viewcontroller; called by viewWillAppear
  func refreshButtonTouchUp() {
    
    // call function to retreive data and store data in the studentsInforamtion array (of structs)
    OTMClient.sharedInstance().retreiveStudentInformation() {
      studentsInformation, errorCode, errorText in
      
      // check to see if data has been retreived
      if let studentsInformation = studentsInformation {
        self.studentsInformation = studentsInformation
        
        dispatch_async(dispatch_get_main_queue()) {
          self.studentInformationTableView.reloadData()
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

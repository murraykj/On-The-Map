//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kevin Murray on 7/27/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  
  @IBOutlet weak var textboxEmail: UITextField!
  @IBOutlet weak var textboxPassword: UITextField!
  
  // Function to process user login request
  @IBAction func btnLogin(sender: UIButton) {
    
    // assign values from the user ID and Password to variables
    let Email = textboxEmail.text
    let Password = textboxPassword.text
    
    // create udacity sesion and validate login credentials
    OTMClient.sharedInstance().createUdacitySession(Email, password: Password){
      success, errorCode, errorText in
      
      // if successful, comlete login process
      if (success == true) && (errorCode == nil) {
        self.completeLogin()
      
      }else {
        // Print error and display alert to the user
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

  // Function to open Udacity web session to allow creation of new account
  @IBAction func btnNewAccount(sender: AnyObject) {
    // Redirect user to Udacity new accounts web page
    UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  
  //Generic function to display alert messages to users
  func displayAlertMessage(title: String, message: String) {
    dispatch_async(dispatch_get_main_queue(), {    let controller = UIAlertController()
      
      // set alert title and message using data passed to function
      controller.title = title
      controller.message = message
      
      // set action buttons for alert message
      let okAction = UIAlertAction (title: "ok", style: UIAlertActionStyle.Default) {
        action in self.dismissViewControllerAnimated(true, completion: nil)
      }
      
      // add buttons and display message
      controller.addAction(okAction)
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
  // Function to display tabbed view after successful login
  func completeLogin() {
    dispatch_async(dispatch_get_main_queue(), {
      
      // display next view controller - tab bar controller
      let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarView") as! UITabBarController
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
}






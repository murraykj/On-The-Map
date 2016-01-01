//
//  OTMUdacity.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/25/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {

  
  //  Udacity API Methods

  // Function used to authenticate with Udacity and check Session ID and account number
  func createUdacitySession(username: String, password: String, completionHandler: (success: Bool, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - Ensure user ID and password parameters are passed in from the calling function
//    println("username: \(username)")
//    println("password:  \(password)")
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.udacitySessionURL)!)

    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(success: false, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        println(error!)
        
      } else {
        
        // 5A - Parse the data and remove first 5 characters
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        println("Initial Login Data:  ")
        println(NSString(data: newData, encoding: NSUTF8StringEncoding)!)
        
        // 5B - Parse the subset  of the original data and create a dictionary object to hold the data
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        
        // 6 - Use the data:  Get the session/account dictionary and get the account number
        if let sessionDictionary = parsedResult.valueForKey("account") as? [String:AnyObject] {
          
          // get Udacity account number and save for later...will need to get first name and last name of user
          let accountNumber = sessionDictionary["key"] as? String
          OTMClient.sharedInstance().udacityAccountID = accountNumber
          println("User's Account Number: \(accountNumber!)")
          
          completionHandler(success: true, errorCode: nil, errorText: nil)
          
        } else {
          // set status code for Alert message to user - invalid credentials
          completionHandler(success: false, errorCode: "Invalid Credentials", errorText: "Account not found or invalid credentials.")
          
          println("Could not find session id in \(parsedResult)")
        }
      }
    }
    
    // Start the request
    task.resume()
    
  }
  
  
  
  // Function used to get Udacity user data - first name and last name needed for map updates
  func getUdacityUserData(completionHandler: (success: Bool, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - No parameters are passed so build URL
    let udacityGetUserDataURL = OTMClient.Constants.udacityGetUserDataURL + OTMClient.sharedInstance().udacityAccountID!
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: udacityGetUserDataURL)!)
    
    // 4 - Make the request
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        // Handle network connection error
        println(error!)
        
        // Display Alert message to user - network error
        completionHandler(success: false, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
      } else {
        
        // 5A - Parse the data and remove first 5 characters
        let newUserData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        println("Initial User Data:  ")
        println(NSString(data: newUserData, encoding: NSUTF8StringEncoding)!)
        
        // 5B - Parse the subset  of the original data and create a dictionary object to hold the data
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(newUserData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        
        // 6A - Use the data:  Get the user data
        if let userdataDictionary = parsedResult.valueForKey("user") as? [String:AnyObject] {
          
          // 6B - get the student's last name from the dictionary and save for future use */
          let userLastName = userdataDictionary["last_name"] as? String
          OTMClient.sharedInstance().udacityLastName = userLastName
          println("The user's last name is: \(userLastName!)")
          
          let userFirstName = userdataDictionary["nickname"] as? String
          OTMClient.sharedInstance().udacityFirstName = userFirstName
          println("The user's first name is: \(userFirstName!)")
          
          completionHandler(success: true, errorCode: nil, errorText: nil)
          
        } else {
          // set status code for Alert message to user - Data Retrieval Error
          completionHandler(success: false, errorCode: "Data Retrieval Error", errorText: "Could not retreive user name.")
          
          println("Could not find session id in \(parsedResult)")
        }
        
      }
    }
    
    // Start the request
    task.resume()
    
  }

  
  // Function used to authenticate with Udacity and get a Session ID
  func deleteUdacitySession(completionHandler: (success: Bool, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - No parameters are passed
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.udacitySessionURL)!)
    request.HTTPMethod = "DELETE"
    
    var xsrfCookie: NSHTTPCookie? = nil
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
      if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    
    if let xsrfCookie = xsrfCookie {
      request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        // Handle network connection error
        println(error!)
        
        // Display Alert message to user - network error
        completionHandler(success: false, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
      } else {
        
        // 5A - Parse the data and remove first 5 characters
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        println("Initial Logout Data:  ")
        println(NSString(data: newData, encoding: NSUTF8StringEncoding)!)
        
        // 5B - Parse the subset  of the original data and create a dictionary object to hold the data
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        
        // 6A - Use the data:  Get the session dictionary
        if let logoutDictionary = parsedResult.valueForKey("session") as? [String:AnyObject] {
          
          // 6B - get the valid session ID from the dictionary */
          let expirationTimeStamp = logoutDictionary["expiration"] as? String
          println("Logout/Expiration Time Stamp: \(expirationTimeStamp!)")
          
          completionHandler(success: true, errorCode: nil, errorText: nil)
        }
      }
    }
    
    // Start the request
    task.resume()
    
  }
  
}

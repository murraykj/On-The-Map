//
//  OTMParse.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/27/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {
  
  //  Parse API Methods

  // Function used to retrieve student information
  func retreiveStudentInformation(completionHandler: (result: [StudentInformation]?, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - Ensure user ID and password parameters are passed in from the calling function
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.parseGetStudentLocationsURL)!)
    request.addValue(OTMClient.Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(OTMClient.Constants.parseRestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(result: nil, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        println(error!)
        
      } else {
      
        // 5 - Parse the data and create a dictionary object to hold the data
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        println("parsed result: \(parsedResult)")
        
        // 6A - Use the data:  Get the session dictionary
        if let results = parsedResult!.valueForKey("results") as? [[String:AnyObject]] {
          
          println("results: \(results)")
 
          var studentsInformation = StudentInformation.studentsFromResults(results)
          
          completionHandler(result: studentsInformation, errorCode: nil, errorText: nil)

        } else {
          dispatch_async(dispatch_get_main_queue()) {
            
            // set status code for Alert message to user - network error
            completionHandler(result: nil, errorCode: "Data Retreival Error", errorText: "Student information could not be downloaded.")
            
            println("Could not find student information in \(parsedResult)")
          }
        }
      }
    }
    
    // Start the request
    task.resume()
  }
  
  
  
  // Function used to authenticate with Udacity and check Session ID and account number
  func postStudentLocation(completionHandler: (success: Bool, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - no parameters are passed in.  They are retreived from the common variables section of OTMClient.swift
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.parsePostStudentLocationURL)!)
    request.HTTPMethod = "POST"
    request.addValue(OTMClient.Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(OTMClient.Constants.parseRestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = "{\"uniqueKey\": \"\(OTMClient.sharedInstance().udacityAccountID!)\", \"firstName\": \"\(OTMClient.sharedInstance().udacityFirstName!)\", \"lastName\": \"\(OTMClient.sharedInstance().udacityLastName!)\",\"mapString\": \"\(OTMClient.sharedInstance().studentLocation!)\", \"mediaURL\": \"\(OTMClient.sharedInstance().studentURL!)\",\"latitude\": \(OTMClient.sharedInstance().studentLatitude!), \"longitude\": \(OTMClient.sharedInstance().studentLongitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
   
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(success: false, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        println(error!)
        
      } else {
        
        // 5 - Parse the subset  of the original data and create a dictionary object to hold the data
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        
        // 6A - Use the data:  Get the session/account dictionary and get the account number
        if let resultsDictionary = parsedResult.valueForKey("createdAt") as? String {
          println("Student information updated successfully on: \(resultsDictionary)")
          
          completionHandler(success: true, errorCode: nil, errorText: nil)
          
        } else {
          // set status code for Alert message to user - invalid credentials
          completionHandler(success: false, errorCode: "Error", errorText: "Your information could not be added.")
          
          println("Could not post student information - Error Info: \(parsedResult)")
        }
      }
    }
    
    // Start the request
    task.resume()
    
  }
  
}
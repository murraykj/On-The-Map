//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/18/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import Foundation
import UIKit

class OTMClient : NSObject {
  
  /* Shared session */
  var session: NSURLSession
  
  /* User data */
  var udacityAccountID : String? = nil
  var udacityFirstName : String? = nil
  var udacityLastName : String? = nil
  var studentLocation : String? = nil
  var studentLatitude : Double? = nil
  var studentLongitude : Double? = nil
  var studentURL : String? = nil
  
  override init() {
    session = NSURLSession.sharedSession()
    super.init()
  }
  
  
  // Shared Instance
  class func sharedInstance() -> OTMClient {
    
    struct Singleton {
      static var sharedInstance = OTMClient()
    }
    
    return Singleton.sharedInstance
  }
  
//  //Generic function to display alert messages to users
//  func displayAlertMessage(title: String, message: String) {
//    dispatch_async(dispatch_get_main_queue(), {    let controller = UIAlertController()
//      
//      // set alert title and message using data passed to function
//      controller.title = title
//      controller.message = message
//      
//      // set action buttons for alert message
//      let okAction = UIAlertAction (title: "ok", style: UIAlertActionStyle.Default) {
//        action in dismissViewControllerAnimated(true, completion: nil)
//      }
//      
//      // add buttons and display message
//      controller.addAction(okAction)
//      presentViewController(controller, animated: true, completion: nil)
//    })
//  }
  
}
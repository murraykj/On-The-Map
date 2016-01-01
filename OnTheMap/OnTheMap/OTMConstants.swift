//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/25/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

import Foundation

extension OTMClient {
  
  // Constants
  struct Constants {
    // URLs for Udacity
    static let udacitySessionURL : String = "https://www.udacity.com/api/session"
    static let udacityGetUserDataURL : String = "https://www.udacity.com/api/users/"
    
    // URLs for Parse
    static let parseGetStudentLocationsURL : String = "https://api.parse.com/1/classes/StudentLocation?limit=100"
    static let parsePostStudentLocationURL : String = "https://api.parse.com/1/classes/StudentLocation"
    
    // Uacity Facebook constants (for later use)
    static let FacebookAPI : String = "365362206864879"
    
    // Parse constants
    static let parseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseRestAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  }
  
}
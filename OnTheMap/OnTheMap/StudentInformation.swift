//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Kevin Murray on 8/16/15.
//  Copyright (c) 2015 Kevin Murray. All rights reserved.
//

// structure to hold student data
struct StudentInformation {

  var createdAt = ""
  var firstName = ""
  var lastName = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0
  var mapString = ""
  var mediaURL = ""
  var objectId = ""
  var uniqueKey = ""
  var updatedAt = ""
  
  /* Construct a Student Info Entry from a dictionary */
  init(dictionary: [String : AnyObject]) {
  
    createdAt = dictionary["createdAt"] as! String
    firstName = dictionary["firstName"] as! String
    lastName = dictionary["lastName"] as! String
    latitude = dictionary["latitude"] as! Double
    longitude = dictionary["longitude"] as! Double
    mapString = dictionary["mapString"] as! String
    mediaURL = dictionary["mediaURL"] as! String
    objectId = dictionary["objectId"] as! String
    uniqueKey = dictionary["uniqueKey"] as! String
    updatedAt = dictionary["updatedAt"] as! String
    
  }

  
  /* Helper: Given an array of dictionaries, convert them to an array of Student Information objects */
  static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
    var studentsInformation = [StudentInformation]()
    
    for result in results {
      studentsInformation.append(StudentInformation(dictionary: result))
    }
    
    return studentsInformation
  }
  
}
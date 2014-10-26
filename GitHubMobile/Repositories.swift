//
//  Repos.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/21/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class Repositories {
    
    var fullName : String
    var description : String?
    var language : String?
    var repoID : Int
    var name : String
    var htmlURL : String
    
    init (repoInfo: NSDictionary) {
        self.fullName = repoInfo["full_name"] as String
        self.description = repoInfo["description"] as? String
        self.language = repoInfo["language"] as? String
        self.repoID = repoInfo["id"] as Int
        self.name = repoInfo["name"] as String
        self.htmlURL = repoInfo["html_url"] as String
    }
    
    class func parseJSONDataIntoRepos(rawJSONData: NSData) -> [Repositories]? {
        var error : NSError?
        
        // If NSJSONSerialization of rawJSONData is a NSDictionary, set to JSONDictionary
        if let JSONDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
            var repos = [Repositories]()
            
            // If JSONDictionary["items"] is a NSArray, set to JSONArray
            if let JSONArray = JSONDictionary["items"] as? NSArray {
                for object in JSONArray { // For objects in JSONArray...
                    if let repo = object as? NSDictionary { // if the objects are NSDictionaries, set to repo...
                        var newRepo = Repositories(repoInfo: repo) // create newRepos from repo objects...
                        repos.append(newRepo) // append newRepo objects to array of Repositories objects
                    }
                }
            }
            
            return repos
        }
        
        return nil
    }

}
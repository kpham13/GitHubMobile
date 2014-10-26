//
//  Users.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/23/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class Users {
    
    var login : String
    var avatarURL : String
    var htmlURL : String
    var fullName : String?
    var location : String?
    var company : String?
    var hirable : Int?
    var publicRepos : Int?
    var email : String?
    
    var avatarImage : UIImage?
    
    init (userInfo: NSDictionary) {
        self.login = userInfo["login"] as String
        self.avatarURL = userInfo["avatar_url"] as String
        self.htmlURL = userInfo["html_url"] as String
        self.fullName = userInfo["name"] as? String
        self.location = userInfo["location"] as? String
        self.company = userInfo["company"] as? String
        self.hirable = userInfo["hireable"] as? Int
        self.publicRepos = userInfo["public_repos"] as? Int
        self.email = userInfo["email"] as? String
    }
    
    // Parsing JSON for user search
    class func parseJSONDataIntoUsers(rawJSONData: NSData) -> [Users]? {
        var error : NSError?
        
        if let JSONDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
            var users = [Users]()
            
            if let JSONArray = JSONDictionary["items"] as? NSArray {
                for object in JSONArray {
                    if let user = object as? NSDictionary {
                        var newUser = Users(userInfo: user)
                        users.append(newUser)
                    }
                }
            }
            
            return users
        }
        
        return nil
    }
    
    // Parsing JSON for authenticated user
    class func parseJSONDataIntoAuthenticatedUser(rawJSONData: NSData) -> Users? {
        var error : NSError?
        
        if let JSONDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
            var user : Users
            
            //println(JSONDictionary)
            var profileUser = Users(userInfo: JSONDictionary)
            user = profileUser
            
            return user
        }
        
        return nil
    }
}
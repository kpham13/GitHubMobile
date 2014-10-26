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
    
    init (userInfo: NSDictionary) {
        self.login = userInfo["login"] as String
        self.avatarURL = userInfo["avatar_url"] as String
    }
    
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
    
    class func parseJSONDataIntoAuthenticatedUser(rawJSONData: NSData) -> Users? {
        var error : NSError?
        
        if let JSONDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
            var user : Users
            
            var profileUser = Users(userInfo: JSONDictionary)
            user = profileUser
            
            return user
        }
        
        return nil
    }
}
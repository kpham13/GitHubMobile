//
//  Repos.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/21/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class Repositories {
    
    var repos : NSDictionary
    var repoID : Int
    var name : String
    var full_name : String
    
    init (repoInfo: NSDictionary) {
        let itemInfo = repoInfo["items"] as NSDictionary
        
        self.repos = repoInfo["items"] as NSDictionary
        self.repoID = itemInfo["id"] as Int
        self.name = itemInfo["name"] as String
        self.full_name = itemInfo["full_name"] as String
    }
    
//    class func parseJSONDataIntoItems(rawJSONData: NSData) -> [Repositories]? {
//        var error : NSError?
//        
//        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
//            
//        }
//    }
    
    
    
    
}
/*
// Factory Method - very common to parse JSON in models rather than ViewControllers because reusability in different controllers
class func parseJSONDataIntoTweets(rawJSONData : NSData) -> [Tweet]? {
    var error : NSError?
    // Using Objective-C NSArray and/or NSDictionary rather than Swift Array/Dictionary
    if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
        var tweets = [Tweet]() // Shorthand to initialize array
        // println(JSONArray[0]) // Actual Twitter JSON
        // JSON file gives a dictionary for each tweet, loop through each JSON dictionary to create tweets
        for JSONDictionary in JSONArray {
            if let tweetDictionary = JSONDictionary as? NSDictionary {
                var newTweet = Tweet(tweetInfo : tweetDictionary)
                tweets.append(newTweet)
            }
        }
        return tweets
    }
    return nil
}

===============================

/*
"items": [
{
"id": 3081286,
"name": "Tetris",
"full_name": "dtrupenn/Tetris",
"owner": {
"login": "dtrupenn",
"id": 872147,
"avatar_url": "https://secure.gravatar.com/avatar/e7956084e75f239de85d3a31bc172ace?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
"gravatar_id": "e7956084e75f239de85d3a31bc172ace",
"url": "https://api.github.com/users/dtrupenn",
"received_events_url": "https://api.github.com/users/dtrupenn/received_events",
"type": "User"
},
"private": false,
"html_url": "https://github.com/dtrupenn/Tetris",
"description": "A C implementation of Tetris using Pennsim through LC4",
"fork": false,
"url": "https://api.github.com/repos/dtrupenn/Tetris",
"created_at": "2012-01-01T00:31:50Z",
"updated_at": "2013-01-05T17:58:47Z",
"pushed_at": "2012-01-01T00:37:02Z",
"homepage": "",
"size": 524,
"stargazers_count": 1,
"watchers_count": 1,
"language": "Assembly",
"forks_count": 0,
"open_issues_count": 0,
"master_branch": "master",
"default_branch": "master",
"score": 10.309712
}
]*/*/
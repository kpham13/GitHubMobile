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
    var description : String
    var language : String
    var repoID : Int
    var name : String
    
    init (repoInfo: NSDictionary) {
        self.fullName = repoInfo["full_name"] as String
        self.description = repoInfo["description"] as String
        self.language = repoInfo["language"] as String
        self.repoID = repoInfo["id"] as Int
        self.name = repoInfo["name"] as String
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
]
*/
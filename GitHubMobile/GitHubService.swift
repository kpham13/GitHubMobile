//
//  GitHubService.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class GitHubService {
    
    //let clientID: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("client_id")
    var clientID : String?
    var clientIDParameter : String?
    var clientSecret : String?
    var clientSecretParameter : String?
    var authenticationConfig : NSURLSessionConfiguration?

    let gitHubURL = "http://10.97.110.74:3000" // "http://10.97.110.74:3000?q=tetris"
    var searchParameter = "?q="
    var searchString = "tetris"
    let scope = "scope=user,repo"

    let gitHubOAuthURL = "https://github.com/login/oauth/authorize?"
    let redirectURL = "redirect_uri=githubmobile://test"
    let gitHubPOSTURL = "https://github.com/login/oauth/access_token"
    
    init() {
        // 7. If OAuth token exists in user defaults, create a NSURLSessionConfiguration with token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as? NSString {
            self.setupConfigurationWithAccessToken(accessToken)
        }
    }
    
    // MARK: - Singleton
    
//    class var sharedInstance: GitHubService {
//        struct Static {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: GitHubService? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = GitHubService()
//        }
//        return Static.instance!
//    }
    
    // MARK: - OAuth
    
    // Determines if OAuth token key exists in user defaults.
    func isAuthenticated() -> Bool {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as? NSString {
            return true
        }
        
        return false
    }
    
    func requestOAuthAccess(id: String, secret: String) {
        self.clientID = id
        self.clientIDParameter = "client_id=\(id)"
        self.clientSecret = secret
        self.clientSecretParameter = "client_secret=\(secret)"
        
        // 5a. Redirect users to request GitHub access
        let parameters = self.clientIDParameter! + "&" + self.redirectURL + "&" + self.scope
        let url = self.gitHubOAuthURL + self.clientIDParameter! + "&" + self.redirectURL + "&" + self.scope
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func handleOAuthURL(callbackURL: NSURL) {
        // 5c. Parse through the URL given by GitHub for request token
        let query = callbackURL.query
        let components = query?.componentsSeparatedByString("code=")
        let code = components?.last
        
        // 5d. Construct the query string for POST call
        let urlQuery = self.clientIDParameter! + "&" + self.clientSecretParameter! + "&" + "code=\(code!)"
        var request = NSMutableURLRequest(URL: NSURL(string: self.gitHubPOSTURL)!)
        request.HTTPMethod = "POST"
        
        var postData = urlQuery.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        let length = postData!.length
        request.setValue("\(length)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("Error!")
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        if let tokenResponse = NSString(data: data, encoding: NSASCIIStringEncoding) {
                            //println(tokenResponse)
                            if let accessToken = self.accessTokenFromResponseString(tokenResponse) {
                                //println(accessToken)
                                
                                // Adding access_token to session configuation header
                                self.setupConfigurationWithAccessToken(accessToken)
                                
                                // Saving OAuth token into user default.
                                NSUserDefaults.standardUserDefaults().setObject("\(accessToken)", forKey: "OAuth")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                //println(accessToken)
                                //println(NSUserDefaults.standardUserDefaults().valueForKey("OAuth"))
                            }
                        }
                    case 400...499:
                        println(httpResponse.statusCode)
                    case 500...599:
                        println(httpResponse.statusCode)
                    default:
                        println(httpResponse.statusCode)
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    // MARK: - Authenticated API requests
    
    // GET request (default)
    func dataTask(completionHandler: (errorDescription: String?, repos: [Repositories]?) -> (Void)) {
        let dataTaskURL = NSURL(string: gitHubURL + searchParameter + searchString)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(dataTaskURL!, completionHandler: { (data, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                var error : NSError?
                
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)

                switch httpResponse.statusCode {
                case 200...299:
                    for header in httpResponse.allHeaderFields {
                        println(header)
                    }
                    
                    //println(json)
                    let repos = Repositories.parseJSONDataIntoRepos(data)
                    println("Good: \(responseString)")
                    completionHandler(errorDescription: nil, repos: repos)
                case 400...499:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Client error.", repos: nil)
                case 500...509:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Server error.", repos: nil)
                default:
                    completionHandler(errorDescription: "Bad Response: \(responseString)", repos: nil)
                }
            }
        })
        
        // Run the task
        dataTask.resume()
    }
    
    // MARK: - Helper methods
    
    // Helper method for returning access_token value from query string. (Source: Andy)
    func accessTokenFromResponseString(string: String) -> String? {
        let parameterPairs = string.componentsSeparatedByString("&")
        
        for pair in parameterPairs {
            let combo = pair.componentsSeparatedByString("=")
            if let key = combo.first {
                if key == "access_token" {
                    return combo.last
                }
            }
        }
        
        return nil
    }
    
    // Setup default HTTP header value with OAuth token.
    func setupConfigurationWithAccessToken(token: String) -> Void {
        self.authenticationConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.authenticationConfig?.HTTPAdditionalHeaders = ["Authorization" : "token \(token)"]
    }
    
//    func downloadTask() {
//        let downloadRequestURL = NSURL(string: gitHubURL)
//        let session = NSURLSession.sharedSession()
//        let downloadTask = session.downloadTaskWithRequest(downloadRequestURL!, completionHandler: { (url, response, error) -> Void in
//            if let httpResponse = response as? NSHTTPURLResponse {
//                var error : NSError?
//                
//                switch httpResponse.statusCode {
//                case 200...204:
//                    for header in httpResponse.allHeaderFields {
//                        println(header)
//                    }
//                default:
//                    println("badResponse")
//                }
//            }
//        })
//        
//        downloadTask.re
//    }
}
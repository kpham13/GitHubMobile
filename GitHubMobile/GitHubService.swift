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
    
    // MARK: - Authenticated API Requests
    // 10
    
    func repoSearch(searchText: String, completionHandler: (errorDescription: String?, repos: [Repositories]?) -> (Void)) {
        // Checks to see if authenticated
        if self.authenticationConfig == nil {
            return()
        }
        
        let searchString = searchText
        let searchDirectory = "/search/repositories?q="
        let searchURL = "https://api.github.com" + searchDirectory + searchString
        let request = NSURLRequest(URL: NSURL(string: searchURL)!)
        
        // Create session using authentication config
        let configuration = self.authenticationConfig!
        let session = NSURLSession(configuration: configuration)
        
        // Create an NSURL Session Data Task
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                var error : NSError?
                
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                switch httpResponse.statusCode {
                case 200...299:
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        var repos = [Repositories]()
                        
                        let repoObjects = Repositories.parseJSONDataIntoRepos(data)
                        repos = repoObjects!
                        completionHandler(errorDescription: nil, repos: repos)
                    })
                case 400...499:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Client error.", repos: nil)
                case 500...599:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Server error.", repos: nil)
                default:
                    completionHandler(errorDescription: "Bad Response: \(responseString)", repos: nil)
                }
            }
        })
        
        // Run the task
        dataTask.resume()
    }
    
    func userSearch(searchText: String, completionHandler: (errorDescription: String?, users: [Users]?) -> (Void)) {
        // Checks to see if authenticated
        if self.authenticationConfig == nil {
            return()
        }
        
        let searchString = searchText
        let searchDirectory = "/search/users?q="
        let searchURL = "https://api.github.com" + searchDirectory + searchString
        let request = NSURLRequest(URL: NSURL(string: searchURL)!)
        
        // Create session using authentication config
        let configuration = self.authenticationConfig!
        let session = NSURLSession(configuration: configuration)
        
        // Create an NSURL Session Data Task
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                var error : NSError?
                
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                switch httpResponse.statusCode {
                case 200...299:
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        var users = [Users]()
                        
                        let userObjects = Users.parseJSONDataIntoUsers(data)
                        users = userObjects!
                        completionHandler(errorDescription: nil, users: users)
                    })
                case 400...499:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Client error.", users: nil)
                case 500...599:
                    completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Server error.", users: nil)
                default:
                    completionHandler(errorDescription: "Bad Response: \(responseString)", users: nil)
                }
            }
        })
        
        // Run the task
        dataTask.resume()
    }
    
    // MARK: - Helper Methods
    
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
    
    // NSOperations - Asynchronous download of user images
    func downloadUserImage(user: Users, completionHandler : (image : UIImage) -> (Void)) {
        var downloadOperation = NSBlockOperation { () -> Void in
            let avatarURL = NSURL(string: user.avatarURL)
            let avatarData = NSData(contentsOfURL: avatarURL!) // Network Call
            let avatarImage = UIImage(data: avatarData!) // Most intensive, converting data to image
            //user.avatarImage = avatarImage
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: avatarImage!) // completionHandler is the image, which will be sent to TableView (i.e cell.avatarImageView.image = avatarImage)
                // self.imageActivity.stopAnimating()
            })
        }
        // downloadOperation.qualityOfService = NSQualityOfService.Background
        NSOperationQueue().addOperation(downloadOperation)
    }
 
}
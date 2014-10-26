//
//  GitHubService.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class GitHubService {
    
    //let clientID : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("client_id")
    var clientID : String?
    var clientIDParameter : String?
    var clientSecret : String?
    var clientSecretParameter : String?
    var authenticationConfig : NSURLSessionConfiguration?
    let gitHubAPI = "https://api.github.com"
    
    init() {
        // 7. If OAuth token exists in user defaults, create a NSURLSessionConfiguration with token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as? NSString {
            self.setupConfigurationWithAccessToken(accessToken)
        }
    }
    
    /*
    // MARK: - Singleton
    
    class var sharedInstance: GitHubService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: GitHubService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = GitHubService()
        }
        return Static.instance!
    }
    */
    
    // MARK: - OAuth
    
    // Determines if OAuth token key exists in user defaults.
    func isAuthenticated() -> Bool {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("OAuth") as? NSString {
            return true
        }
        
        return false
    }
    
    func requestOAuthAccess(id: String, secret: String) {
        let gitHubOAuthURL = "https://github.com/login/oauth/authorize?"
        let redirectURL = "redirect_uri=githubmobile://test"
        let scope = "scope=user,repo"
        self.clientID = id
        self.clientIDParameter = "client_id=\(id)"
        self.clientSecret = secret
        self.clientSecretParameter = "client_secret=\(secret)"
        
        // 5a. Redirect users to request GitHub access
        let parameters = self.clientIDParameter! + "&" + redirectURL + "&" + scope
        let url = gitHubOAuthURL + self.clientIDParameter! + "&" + redirectURL + "&" + scope
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func handleOAuthURL(callbackURL: NSURL) {
        let gitHubTokenURL = "https://github.com/login/oauth/access_token"
        
        // 5c. Parse through the URL given by GitHub for request token
        let query = callbackURL.query
        let components = query?.componentsSeparatedByString("code=")
        let code = components?.last
        
        // 5d. Construct the query string for POST call
        let urlQuery = self.clientIDParameter! + "&" + self.clientSecretParameter! + "&" + "code=\(code!)"
        var request = NSMutableURLRequest(URL: NSURL(string: gitHubTokenURL)!)
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
                            if let accessToken = self.accessTokenFromResponseString(tokenResponse) {
                                // Adding access_token to session configuation header
                                self.setupConfigurationWithAccessToken(accessToken)
                                
                                // Saving OAuth token into user defaults
                                NSUserDefaults.standardUserDefaults().setObject("\(accessToken)", forKey: "OAuth")
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                        }
                    case 400...499:
                        println("Client error: \(httpResponse.statusCode)")
                    case 500...599:
                        println("Server error: \(httpResponse.statusCode)")
                    default:
                        println("Bad response: \(httpResponse.statusCode)")
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
        let searchURL = self.gitHubAPI + searchDirectory + searchString
        let request = NSURLRequest(URL: NSURL(string: searchURL)!)
        
        // Create session using authentication config
        let configuration = self.authenticationConfig!
        let session = NSURLSession(configuration: configuration)
        
        // Create an NSURL Session Data Task
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("Error!")
            } else {
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
        let searchURL = self.gitHubAPI + searchDirectory + searchString
        let request = NSURLRequest(URL: NSURL(string: searchURL)!)
        
        // Create session using authentication config
        let configuration = self.authenticationConfig!
        let session = NSURLSession(configuration: configuration)
        
        // Create an NSURL Session Data Task
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("Error!")
            } else {
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
            }
        })
        
        // Run the task
        dataTask.resume()
    }

    func fetchUserProfile(completionHandler: (errorDescription: String?, user: Users?) -> (Void)) {
        // Checks to see if authenticated
        if self.authenticationConfig == nil {
            return()
        }
        
        let searchDirectory = "/user"
        let searchURL = self.gitHubAPI + searchDirectory
        let request = NSURLRequest(URL: NSURL(string: searchURL)!)
        
        // Create session using authentication config
        let configuration = self.authenticationConfig!
        let session = NSURLSession(configuration: configuration)
        
        // Create an NSURL Session Data Task
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("Error!")
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    var error : NSError?
                    
                    let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            var user : Users
                            
                            let userObject = Users.parseJSONDataIntoAuthenticatedUser(data)
                            user = userObject!
                            completionHandler(errorDescription: nil, user: user)
                        })
                    case 400...499:
                        completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Client error.", user: nil)
                    case 500...599:
                        completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Server error.", user: nil)
                    default:
                        completionHandler(errorDescription: "Bad Response: \(responseString)", user: nil)
                    }
                }
            }
        })
        
        // Run the task
        dataTask.resume()
    }
    
    func updateUserProfile(completionHandler: (errorDescription: String?, user: Users?) -> (Void)) {
        // Checks to see if authenticated
        if self.authenticationConfig == nil {
            return()
        }
      
        let searchDirectory = "/user"
        let searchURL = "https://api.github.com" + searchDirectory
        var request = NSMutableURLRequest(URL: NSURL(string: searchURL)!)
        request.HTTPMethod = "PATCH"
////////////        
////////////        /*
////////////        https://developer.github.com/v3/users/
////////////            {
////////////                "name": "monalisa octocat",
////////////                "email": "octocat@github.com",
////////////                "blog": "https://github.com/blog",
////////////                "company": "GitHub",
////////////                "location": "San Francisco",
////////////                "hireable": true,
////////////                "bio": "There once..."
////////////            }
////////////        */
////////////        
////////////        // Create session using authentication config
////////////        let configuration = self.authenticationConfig!
////////////        let session = NSURLSession(configuration: configuration)
////////////        
////////////        // Create an NSURL Session Data Task
////////////        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
////////////            if error != nil {
////////////                println("Error!")
////////////            } else {
////////////                if let httpResponse = response as? NSHTTPURLResponse {
////////////                    var error : NSError?
////////////                    
////////////                    let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
////////////                    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
////////////                    
////////////                    switch httpResponse.statusCode {
////////////                    case 200...299:
////////////                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
////////////                            var user : Users
////////////                            
////////////                            let userObject = Users.parseJSONDataIntoAuthenticatedUser(data)
////////////                            user = userObject!
////////////                            completionHandler(errorDescription: nil, user: user)
////////////                        })
////////////                    case 400...499:
////////////                        completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Client error.", user: nil)
////////////                    case 500...599:
////////////                        completionHandler(errorDescription: "Status Code: \(httpResponse.statusCode). Server error.", user: nil)
////////////                    default:
////////////                        completionHandler(errorDescription: "Bad Response: \(responseString)", user: nil)
////////////                    }
////////////                }
////////////            }
////////////        })
////////////        
////////////        // Run the task
////////////        dataTask.resume()
    }
////////////    
////////////    // Create a repo: https://developer.github.com/v3/repos/#create
////////////    
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

    // NSOperations - asynchronous download of user images
    func downloadUserImage(user: Users, completionHandler : (image : UIImage) -> (Void)) {
        var downloadOperation = NSBlockOperation { () -> Void in
            let avatarURL = NSURL(string: user.avatarURL)
            let avatarData = NSData(contentsOfURL: avatarURL!)
            let avatarImage = UIImage(data: avatarData!)
            user.avatarImage = avatarImage
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: avatarImage!)
            })
        }
        
        NSOperationQueue().addOperation(downloadOperation)
    }

}
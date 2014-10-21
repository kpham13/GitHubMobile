//
//  GitHubService.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class GitHubService {
    
    let gitHubURL = "http://10.97.110.74:3000" // "http://10.97.110.74:3000?q=tetris"
    var searchParameter = "?q="
    var searchString = "tetris"
    
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



//    
//    // Makes GET request, uses temporary file behind the scenes.
//    func downloadTask() {
//        let request = NSURLRequest(URL: url2!)
//        let session = NSURLSession.sharedSession()
//        let downloadTask = session.downloadTaskWithRequest(request, completionHandler: { (url, response, error) -> Void in
//            if let httpResponse = response as? NSHTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...204:
//                    for header in httpResponse.allHeaderFields {
//                        println(header)
//                    }
//                default:
//                    println("badResponse: \(httpResponse.statusCode)")
//                }
//            }
//        })
//        
//        downloadTask.resume()
//    }
//    
//}
//
//  GitHubService.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class GitHubService {
    
    let gitHubURL = NSURL(string: "http://10.97.110.74:3000?q=tetris")
    let url2 = NSURL(string: "")

    // Makes GET request, by default
    func dataTask(completionHandler: (errorDescription: String?, json: NSDictionary) -> (Void)) {
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(gitHubURL, completionHandler: { (data, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                var error : NSError?
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                switch httpResponse.statusCode {
                case 200...204:
                    for header in httpResponse.allHeaderFields {
                        println(header)
                    }
                    
                    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    completionHandler(errorDescription: "Response String: \(responseString)", json: json)
                default:
                    completionHandler(errorDescription: "Bad Response: \(httpResponse.statusCode)", json: json)
                }
            }
        })
        
        // Run the task
        dataTask.resume()
        
    }
    
    // Makes GET request, uses temporary file behind the scenes.
    func downloadTask() {
        let request = NSURLRequest(URL: url2)
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithRequest(request, completionHandler: { (url, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...204:
                    for header in httpResponse.allHeaderFields {
                        println(header)
                    }
                default:
                    println("badResponse: \(httpResponse.statusCode)")
                }
            }
        })
        
        downloadTask.resume()
    }
    
}
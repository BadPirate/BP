//
//  NSURLSession+BP.swift
//  Node War
//
//  Created by Kevin Lohman on 1/1/15.
//  Copyright (c) 2015 Logic High. All rights reserved.
//

import Foundation

extension NSURLSession {
    func getForServer(server: String, scheme: String, path: String, cachePolicy: NSURLRequestCachePolicy, timeout: NSTimeInterval, parameters: Dictionary<String,String>?, completionHandler: ((data: NSData?, response : NSURLResponse?, error : NSError?, result: AnyObject?) -> Void)) {
        self.dataForServer(false, server: server, scheme: scheme, path: path, cachePolicy: cachePolicy, timeout: timeout, parameters: parameters, completionHandler: completionHandler)
    }
    func postForServer(server: String, scheme: String, path: String, cachePolicy: NSURLRequestCachePolicy, timeout: NSTimeInterval, parameters: Dictionary<String,String>?, completionHandler: ((data: NSData?, response : NSURLResponse?, error : NSError?, result: AnyObject?) -> Void))
    {
        self.dataForServer(true, server: server, scheme: scheme, path: path, cachePolicy: cachePolicy, timeout: timeout, parameters: parameters, completionHandler: completionHandler)
    }
    func dataForServer(isPost: Bool, server: String, scheme: String, path: String, cachePolicy: NSURLRequestCachePolicy, timeout: NSTimeInterval, parameters: Dictionary<String,String>?, completionHandler: ((data: NSData?, response : NSURLResponse?, error : NSError?, result: AnyObject?) -> Void))
    {
        var mutablePath = path
        if (!isPost && parameters != nil)
        {
            if let parameterString : String = String.queryStringFromParameters(parameters!) {
                mutablePath += parameterString
            }
        }
        let URL = NSURL(scheme: scheme, host: server, path: mutablePath)
        let request = NSMutableURLRequest(URL: URL!, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.HTTPMethod = isPost ? "POST" : "GET"
        if(isPost && parameters != nil)
        {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters!, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-type")
        }
        self.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var result : AnyObject? = nil
            if let mime = response?.MIMEType
            {
                switch(mime)
                {
                case "application/json":
                    result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                case "text/html":
                    let controller = SVModalWebViewController(URL: response!.URL)
                    controller.modalDelegate = self
                    UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(controller, animated: true, completion: nil)
                default: break
                }
            }
            completionHandler(data: data, response: response, error: error, result: result)
        }).resume()
    }
}
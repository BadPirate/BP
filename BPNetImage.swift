//
//  BPNetImage.swift
//  Node War
//
//  Created by Kevin Lohman on 1/2/15.
//  Copyright (c) 2015 Logic High. All rights reserved.
//

import Foundation
import UIKit

// Image that will load itself nicely from the web, can be set multiple times, useful for UITableViewCell objects

private var _imageSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())

class BPNetImage : UIImageView {
    private var _task : NSURLSessionDataTask?
    var URL : NSURL? {
        willSet {
            if let dataTask = _task {
                dataTask.cancel()
                _task = nil
            }
        }
        didSet {
            if (URL == nil) {
                return
            }
            self.image = nil
            let request = NSURLRequest(URL: URL!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
            _task = _imageSession.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (self._task == nil) {
                    return // Cancelled
                }
                self._task = nil
                
                if let e = error
                {
                    if (e.code == -999)
                    {
                        return // Cancelled
                    }
                    NSLog("Error Loading Image: %@",e.localizedDescription)
                    return
                }
                if let d = data
                {
                    if let dataImage : UIImage = UIImage(data: d)
                    {
                        self.image = dataImage
                    }
                    else
                    {
                        NSLog("Could not generate image from data - %@", d)
                    }
                }
                else
                {
                    NSLog("No data - %@", response!)
                }

            })
            _task!.resume()
        }
    }
}
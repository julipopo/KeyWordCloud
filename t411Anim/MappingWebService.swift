//
//  MappingWebService.swift
//  t411Anim
//
//  Created by Julien Simmer on 24/04/2017.
//  Copyright © 2017 Julien Simmer . All rights reserved.
//

import UIKit

class MappingWebService: NSObject {

    
    //http://swiftdeveloperblog.com/http-get-request-example-in-swift/
    
    class func getWordsMapping(word: String, success: @escaping (NSArray) -> Void, failure: @escaping (Error) -> Void) {
        print("test")
        let scriptUrl = "http://julipopo.freeboxos.fr/mappingWord/32/" + word
        let myUrl = NSURL(string: scriptUrl)
        let request = NSMutableURLRequest(url:myUrl! as URL)
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil
            {
                print(error!)
                failure(error!)
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString ?? "defaut Value :/")")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    let array = convertedJsonIntoDict.object(forKey: "output") as? NSArray
                    
                    if array != nil {
                        success(array!)
                    } else {
                        failure("error from parsing" as! Error)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                failure(error)
            }
            
        }
        
        task.resume()
    }
        
}

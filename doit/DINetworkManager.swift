//
//  DINetworkManager.swift
//  doit
//
//  Created by Illia on 5/25/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import Foundation
import CoreLocation

let kAPIURL = "http://api.doitserver.in.ua"

//MARK: Login 
let kUserNameKey = "username"
let kEmailKey = "email"
let kPasswordKey = "password"
let kTokenKey = "token"
let kAvatarKey = "avatar"

//MARK: Image
let kImageKey = "image"
let kDescriptionKey = "description"
let kHashtagKey = "hashtag"
let kLatitudeKey = "latitude"
let kLongitudeKey = "longitude"
let kImagesKey = "images"

let kGifKey = "gif"

class DINetworkManager : NSObject
{
    class func loginWithName(_ aName:String?, anEmail:String, aPassword:String, anImageURL:URL, completion:@escaping(_ inToken:String?) -> Void)
    {
        let params = [kUserNameKey:aName ?? "", kEmailKey:anEmail , kPasswordKey:aPassword]
        DINetworkManager.manager.post(kAPIURL + "/create", parameters:params, constructingBodyWith:
        { (fromData:AFMultipartFormData) in
            do
            {
                try fromData.appendPart(withFileURL:anImageURL, name:kAvatarKey)
            }
            catch let err
            {
                NSLog(err.localizedDescription)
                completion(nil)
            }
        },
        success:
        { (_:AFHTTPRequestOperation, obj:Any) in
            if let info = obj as? [String:Any],
                let token = info[kTokenKey] as? String
            {
                completion(token)
            }
            else
            {
                NSLog("Cannot serrialize JSON")
                completion(nil)
            }
        },
        failure:
        { (_:AFHTTPRequestOperation?, err:Error) in
            NSLog(err.localizedDescription)
            completion(nil)
        })
    }
    
    class func getAllImages(aToken:String, completion:@escaping(_ inImages:[[String:Any]]?) -> Void)
    {
        let manager = DINetworkManager.manager
        if manager.requestSerializer.value(forHTTPHeaderField:kTokenKey) != aToken
        {
            manager.requestSerializer.setValue(aToken, forHTTPHeaderField:kTokenKey)
        }
        let urlString = kAPIURL + "/all"
        manager.get(urlString, parameters:nil, success:
        { (_:AFHTTPRequestOperation, obj:Any) in
            if let theResponseInfo = obj as? [String:Any],
                let theImages = theResponseInfo[kImagesKey] as? [[String : Any]]
            {
                completion(theImages)
            }
            else
            {
                completion(nil)
            }
        })
        { (_:AFHTTPRequestOperation?, err:Error) in
            NSLog(err.localizedDescription)
            completion(nil)
        }

    }
    
    class func postImage(_ aToken:String, aFileURL:URL, aDescription:String, aHashtag:String, aLocation:CLLocation, completion:@escaping(_ success:Bool) -> Void)
    {
        let manager = DINetworkManager.manager
        if manager.requestSerializer.value(forHTTPHeaderField:kTokenKey) != aToken
        {
            manager.requestSerializer.setValue(aToken, forHTTPHeaderField:kTokenKey)
        }
        
        let latitude = Float(aLocation.coordinate.latitude)
        let longitude = Float(aLocation.coordinate.longitude)
        let params:[String : Any] = [kDescriptionKey:aDescription, kHashtagKey:aHashtag , kLatitudeKey:latitude, kLongitudeKey:longitude]
        DINetworkManager.manager.post(kAPIURL + "/image", parameters:params, constructingBodyWith:
        { (fromData:AFMultipartFormData) in
            do
            {
                try fromData.appendPart(withFileURL:aFileURL, name:kImageKey)
            }
            catch let err
            {
                NSLog(err.localizedDescription)
                completion(false)
            }
        },
        success:
        { (_:AFHTTPRequestOperation, obj:Any) in
            completion(true)
        },
        failure:
        { (_:AFHTTPRequestOperation?, err:Error) in
            NSLog(err.localizedDescription)
            completion(false)
        })
    }
    
    class func getGIF(_ aToken:String, weather:String, completion:@escaping(_ urlString:String?) -> Void)
    {
        let manager = DINetworkManager.manager
        if manager.requestSerializer.value(forHTTPHeaderField:kTokenKey) != aToken
        {
            manager.requestSerializer.setValue(aToken, forHTTPHeaderField:kTokenKey)
        }
        
        let params:[String : Any] = [kWeatherKey:weather]
        DINetworkManager.manager.get(kAPIURL + "/gif", parameters:params, success:
        { (_:AFHTTPRequestOperation, obj:Any) in
            var theURLString:String?
            if let theInfo = obj as? [String:Any]
            {
                theURLString = theInfo[kGifKey] as? String
            }
            completion(theURLString)
        }, failure:
        { (_:AFHTTPRequestOperation?, err:Error) in
            completion(nil)
        })
    }
    
    //MARK: - Private
    private static var manager:AFHTTPRequestOperationManager =
    {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        return manager
    }()
}
			

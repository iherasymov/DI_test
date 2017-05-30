//
//  DIImageItem.swift
//  doit
//
//  Created by Illia on 5/26/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import Foundation

typealias Parameters = (weather:String, longitude:Float, latitude:Float)

let kSmallImagePathKey = "smallImagePath"
let kBigImagePathKey = "bigImagePath"
let kIdKey = "id"
let kCreatedDateKey = "createdDate"
let kWeatherKey = "weather"
let kParametersKey = "parameters"

class DIImageItem : NSObject
{
    let smallImagePath:String
    let bigImagePath:String
    let id:Int
    let hashtag:String
    let createdDate:String
    let descriptionText:String
    let parameters:Parameters
    private(set) var localSmallImageURL:URL?
    private(set) var localBigImageURL:URL?
    
    private(set) static var loadImagesQueue:OperationQueue =
    {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    required init(withInfo anInfo:[String:Any])
    {
        self.smallImagePath = anInfo[kSmallImagePathKey] as? String ?? ""
        self.bigImagePath = anInfo[kBigImagePathKey] as? String ?? ""
        self.id = anInfo[kIdKey] as? Int ?? 0
        self.hashtag = anInfo[kHashtagKey] as? String ?? ""
        self.createdDate = anInfo[kCreatedDateKey] as? String ?? ""
        self.descriptionText = anInfo[kDescriptionKey] as? String ?? ""
        
        let parameters = anInfo[kParametersKey] as? [String:Any] ?? [:]
        let theWeather = parameters[kWeatherKey] as? String ?? ""
        let theLongitude = parameters[kLongitudeKey] as? Float ?? Float(0)
        let theLatitude = parameters[kLatitudeKey] as? Float ?? Float(0)
        self.parameters = (theWeather, theLongitude, theLatitude)
        super.init()
    }
    
    func loadSmallImage(_ completion:(@escaping(_ success:Bool) -> Void))
    {
        let url = URL(fileURLWithPath:self.smallImagePath)
        self.loadImage(fromURL:url)
        { (anURL:URL?) in
            self.localSmallImageURL = anURL
            completion(nil != self.localSmallImageURL)
        }
    }
    
    func loadBigImage(_ completion:(@escaping(_ success:Bool) -> Void))
    {
        let url = URL(fileURLWithPath:self.bigImagePath)
        self.loadImage(fromURL:url)
        { (anURL:URL?) in
            self.localBigImageURL = anURL
            completion(nil != self.localBigImageURL)
        }
    }
    
//MARK: - Private
    func loadImage(fromURL anURL:URL, completion:(@escaping(_ url:URL?) -> Void))
    {
        var theURL:URL?
        let operation = BlockOperation(block:
        {
            do
            {
                let theSmallImageURL = CreateTemporaryImageURL()
                if let remoteURL = URL(string:self.smallImagePath)
                {
                    let data = try Data(contentsOf: remoteURL)
                    try data.write(to:theSmallImageURL)
                    theURL = theSmallImageURL
                }
            }
            catch
            {}
        })
        operation.queuePriority = .normal
        operation.completionBlock =
        {
            OperationQueue.main.addOperation
            {
                completion(theURL)
            }
        }
        
        DIImageItem.loadImagesQueue.addOperation(operation)
    }
}

func CreateTemporaryImageURL() -> URL
{
    return URL(fileURLWithPath:(NSTemporaryDirectory() + "\(UUID().uuidString).png"))
}

//
//  DICollectionViewController.swift
//  doit
//
//  Created by Illia Herasymov on 4/9/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit
import CoreLocation

private let kCellReuseIdentifier = "ImageCell"

class DICollectionViewController: UICollectionViewController
{
    
    @IBOutlet weak var generateButton: UIButton!
    var imageItems:[DIImageItem] = []
    var location:CLLocation?
    lazy var loadImagesQueue:OperationQueue =
    {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var locationManager:CLLocationManager =
    {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        return locationManager
    }()
    
    lazy var gifPopupViewController:DIGifPopupViewController =
    {
        let storyboard = self.storyboard!
        let viewController = storyboard.instantiateViewController(withIdentifier:kDIGifPopupViewControllerID) as! DIGifPopupViewController
        viewController.delegate = self
        return viewController
    }()
    
    var underViewFrame:CGRect
    {
        return CGRect(x:0,
                      y:self.view.bounds.size.height,
                      width:self.view.bounds.size.width,
                      height:self.view.bounds.size.height)
    }
    
//MARK: Override
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let attrStr = NSAttributedString(string:"G", attributes:[NSUnderlineStyleAttributeName: 1])
        self.generateButton.setAttributedTitle(attrStr, for: .normal)
        _ = self.locationManager
        self.getAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let theDestinationViewController = segue.destination as? DIAddImageViewController
        {
            theDestinationViewController.delegate = self
        }
    }
    
    @IBAction func onGif(_ sender: Any)
    {
        guard let token = UserDefaults.standard.object(forKey: kTokenKey) as? String,
              let weather = self.imageItems.last?.parameters.weather
        else
        {
            return
        }
        
        DINetworkManager.getGIF(token, weather:weather)
        { (gifURLStr:String?) in
            
            if let pathToGIF = gifURLStr,
               let remoteURL = URL(string:pathToGIF)
            {
                var image:UIImage?
                let operation = BlockOperation(block:
                {
                    do
                    {
                        let data = try Data(contentsOf: remoteURL)
                        image = UIImage.gifImageWithData(data)
                    }
                    catch
                    {}
                })
                operation.queuePriority = .high
                operation.completionBlock =
                {
                    OperationQueue.main.addOperation
                    {
                        self.gifPopupViewController.view.frame = self.underViewFrame
                        self.gifPopupViewController.image = image
                        
                        self.view.addSubview(self.gifPopupViewController.view)
                        self.addChildViewController(self.gifPopupViewController)
                        UIView.animate(withDuration:0.3, animations:
                        {
                            self.gifPopupViewController.view.frame = self.view.bounds
                        })
                        { (_:Bool) in
                            self.navigationController?.setNavigationBarHidden(true, animated:true)
                        }
                    }
                }
                DIImageItem.loadImagesQueue.addOperation(operation)
            }
        }
    }
    
// MARK: -
    func getAll()
    {
        guard let token = UserDefaults.standard.object(forKey: kTokenKey) as? String
        else
        {
            return
        }
        
        var indexPathsForDelete:[IndexPath] = []
        for i in 0..<self.imageItems.count
        {
            indexPathsForDelete.append(IndexPath(row:i, section:0))
        }
        
        self.imageItems = []
        self.collectionView?.deleteItems(at:indexPathsForDelete)
        DINetworkManager.getAllImages(aToken:token)
        { (inImages:[[String : Any]]?) in
            if let theImageInfos = inImages
            {
                for i in 0..<theImageInfos.count
                {
                    let imageInfo = theImageInfos[i]
                    let imageItem = DIImageItem(withInfo:imageInfo)
                    imageItem.loadSmallImage
                    { (success:Bool) in
                        if success
                        {
                            let indexPath = IndexPath(row:i, section:0)
                            self.imageItems.append(imageItem)
                            self.collectionView?.insertItems(at:[indexPath])
                        }
                    }
                }
            }
        }
    }

// MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView)
    -> Int
    {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
    -> Int
    {
        return self.imageItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:kCellReuseIdentifier, for:indexPath) as? DIImageCell
        else
        {
            return UICollectionViewCell()
        }
        let imageItem = self.imageItems[indexPath.row]
        if let theImgPath = imageItem.localSmallImageURL?.path
        {
            cell.imageView.image = UIImage(contentsOfFile:theImgPath)
            cell.weather.text = imageItem.parameters.weather
            let loacation = CLLocation(latitude:CLLocationDegrees(imageItem.parameters.latitude), longitude:    CLLocationDegrees(imageItem.parameters.longitude))
            self.getAddressFromLocation(loacation, completion:
            { (address:String) in
                cell.address.text = address
            })
        }
        return cell
    }
    
    func getAddressFromLocation(_ aLocation:CLLocation, completion:@escaping ((String) -> Void))
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(aLocation)
        { (aPlacemarks:[CLPlacemark]?, anErr:Error?) in
            if let thePlacemarks = aPlacemarks,
                thePlacemarks.count > 0,
                let placemark = thePlacemarks.last
            {
                OperationQueue.main.addOperation
                {
                    completion("\(placemark.name ?? "") \(placemark.postalCode ?? "") \(placemark.locality ?? "")")
                }
            }
        }
    }
}

extension DICollectionViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)
    -> CGSize
    {
        return CGSize(width:collectionView.bounds.size.width / 3, height: collectionView.bounds.size.height / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)
    -> UIEdgeInsets
    {
        let topOffset = CGFloat(10)
        let bottomOffset = CGFloat(10)
        return UIEdgeInsets(top:topOffset,
                            left:CGFloat(collectionView.bounds.size.width / 8.0),
                            bottom: bottomOffset,
                            right:CGFloat(collectionView.bounds.size.width / 8.0))
    }
}

extension DICollectionViewController : DIAddImageViewControllerDelegate
{
    func addImageViewController(_ aViewController:DIAddImageViewController, anImage:UIImage, description:String, hashtag:String)
    {
        let url = CreateTemporaryImageURL()
        do
        {
            if let scaledImg = anImage.scaledImage(400)
            {
                try UIImagePNGRepresentation(scaledImg)?.write(to:url)
                if let theToken = UserDefaults.standard.value(forKey:kTokenKey) as? String,
                    let coordiname = self.locationManager.location?.coordinate
                {
                    let location = CLLocation(latitude:coordiname.latitude, longitude:coordiname.longitude)
                    DINetworkManager.postImage(theToken, aFileURL:url, aDescription:description, aHashtag:hashtag, aLocation:location, completion:
                    {(success:Bool) in
                        if success
                        {
                            self.getAll()
                            try? FileManager.default.removeItem(at:url)
                        }
                    })
                }
            }
        }
        catch let err
        {
            NSLog(err.localizedDescription)
        }
        
        aViewController.navigationController?.popViewController(animated:true)
    }
}

extension DICollectionViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error.localizedDescription)
    }
}

extension DICollectionViewController : DIGifPopupViewControllerDelegate
{
    func dissmissViewController(_ gifPopupViewController:DIGifPopupViewController)
    {
        gifPopupViewController.removeFromParentViewController()
        UIView.animate(withDuration:0.3, animations:
        {
            gifPopupViewController.view.frame = self.underViewFrame
        })
        { (_:Bool) in
            gifPopupViewController.view.removeFromSuperview()
            gifPopupViewController.removeFromParentViewController()
            self.navigationController?.setNavigationBarHidden(false, animated:true)
        }
    }
}

class DIImageCell : UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var address: UILabel!
}

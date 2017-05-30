//
//  DIIWaitViewConroller.swift
//  doit
//
//  Created by Illia on 5/30/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import Foundation

fileprivate let kDIWaitViewRestorationID : String = UUID().uuidString

protocol DIIWaitViewController : class
{
    func startWait()
    func endWait()
}

extension UIViewController : DIIWaitViewController
{
    func startWait()
    {
        let waitView = UIVisualEffectView(frame:self.view.bounds)
        waitView.effect = UIBlurEffect(style:.light)
        waitView.restorationIdentifier = kDIWaitViewRestorationID
        self.view.addSubview(waitView)
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        waitView.contentView.addSubview(activity)
        activity.center = waitView.contentView.center
        activity.startAnimating()
        self.navigationController?.setNavigationBarHidden(true, animated:true)
    }
    
    func endWait()
    {
        self.view.subviews.forEach
        {
            if $0.restorationIdentifier == kDIWaitViewRestorationID
            {
                $0.removeFromSuperview()
            }
        }
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
}

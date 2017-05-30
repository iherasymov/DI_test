//
//  DIGifpopupViewController.swift
//  doit
//
//  Created by Illia on 5/30/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit

let kDIGifPopupViewControllerID = "GifPopupViewController"

protocol DIGifPopupViewControllerDelegate : class
{
    func dissmissViewController(_ gifPopupViewController:DIGifPopupViewController)
}

class DIGifPopupViewController : DITapableViewcontroller
{
    weak var delegate:DIGifPopupViewControllerDelegate?
    var image:UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
        self.imageView.animationDuration = 3.0
        self.imageView.animationRepeatCount = Int(INT_MAX)
    }
    
    override func onTap(_ sender: Any)
    {
        self.delegate?.dissmissViewController(self)
    }
}

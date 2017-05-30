//
//  DILoadImageViewController.swift
//  doit
//
//  Created by Illia on 5/25/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit

class DILoadImageViewController: DITapableViewcontroller
{
    func imageDidLoad(_ anImage:UIImage?)
    {
    }
    
    func loadImage()
    {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle:.actionSheet)
        let cameraAction = UIAlertAction(title:"Camera", style:.`default`)
        { (action:UIAlertAction) in
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated:true, completion:nil)
        }
        alertController.addAction(cameraAction)
        
        let photoLibrary = UIAlertAction(title:"Photo Library", style:.`default`)
        { (action:UIAlertAction) in
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated:true, completion:nil)
        }
        alertController.addAction(photoLibrary)
        
        let cancel = UIAlertAction(title:"Cancel", style:.cancel)
        { (action:UIAlertAction) in
            alertController.dismiss(animated:true, completion:nil)
        }
        alertController.addAction(cancel)
        
        self.present(alertController, animated:true, completion:nil)
    }
}

extension DILoadImageViewController : UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.imageDidLoad(img)
        }
        picker.dismiss(animated:true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated:true, completion:nil)
    }
}

extension DILoadImageViewController : UINavigationControllerDelegate
{
}


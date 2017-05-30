//
//  DIAddImageViewControllerViewController.swift
//  doit
//
//  Created by Illia on 5/25/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit
protocol DIAddImageViewControllerDelegate : class
{
    func addImageViewController(_ aViewController:DIAddImageViewController, anImage:UIImage, description:String, hashtag:String)
}

class DIAddImageViewController: DILoadImageViewController
{
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var hashtagTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    weak var delegate:DIAddImageViewControllerDelegate?
    
    override func viewDidLoad()
    {
        self.validateDoneButton(aDescription:"", aHashtag:"")
        super.viewDidLoad()
    }
    
    override func imageDidLoad(_ anImage: UIImage?)
    {
        self.addImage.setImage(nil, for:.normal)
        self.imageView.image = anImage
        self.validateDoneButton(aDescription:self.descriptionTextField.text ?? "", aHashtag:self.hashtagTextField.text ?? "")
    }
    
    override var textFields: [UITextField]
    {
        return [self.descriptionTextField, self.hashtagTextField]
    }
    
    @IBAction func onAddImage(_ sender: Any)
    {
        self.loadImage()
    }
    
    @IBAction func onDone(_ sender: Any)
    {
        self.delegate?.addImageViewController(self, anImage:self.imageView.image!, description:self.descriptionTextField.text!, hashtag:self.hashtagTextField.text!)
    }
    
    func validateDoneButton(aDescription:String?, aHashtag:String?)
    {
        var doneIsEnabled = false
        if let theDescription = aDescription,
            let theHashtag = aHashtag
        {
            doneIsEnabled = theDescription.characters.count > 0 && theHashtag.characters.count > 0
        }
        doneIsEnabled = doneIsEnabled && nil != self.imageView.image
        self.doneButton.isEnabled = doneIsEnabled
        self.doneButton.setTitleColor(doneIsEnabled ? self.doneButton.tintColor : UIColor.lightGray, for:.normal)
    }
}

extension DIAddImageViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField)
    -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String)
    -> Bool
    {
        var theDescription:String? = nil
        var theHashtag:String? = nil
        if let theNSText = textField.text as NSString?
        {
            let theText = theNSText.replacingCharacters(in:range, with:string)
            if textField === self.descriptionTextField
            {
                theDescription = theText
                theHashtag = self.hashtagTextField.text
            }
            else if textField === self.hashtagTextField
            {
                theDescription = self.descriptionTextField.text
                theHashtag = theText
            }
            
        }
        self.validateDoneButton(aDescription:theDescription, aHashtag:theHashtag)
        return true
    }
}

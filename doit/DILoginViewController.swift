//
//  ViewController.swift
//  doit
//
//  Created by Illia Herasymov on 4/7/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit

enum DILoginTextFieldRestirationID : String
{
    case UserNameTextFieldRestorationID = "userName"
    case EmailTextFieldRestorationID = "email"
    case PasswordTextFieldRestorationID = "password"
}

let kShowGalerySegueID = "showGalery"

class DILoginViewController: DILoadImageViewController
{
    let kDefaultLogoHeight = 100.0
    
    @IBOutlet weak var avaView: UIImageView!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    var avaURL:URL?

//MARK: - Override
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.startWait()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        guard nil == UserDefaults.standard.value(forKey:kTokenKey)
        else
        {
            self.endWait()
            self.performSegue(withIdentifier:kShowGalerySegueID, sender:self)
            return
        }
        self.endWait()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated:false)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name:.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name:.UIKeyboardWillHide, object:nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func imageDidLoad(_ anImage: UIImage?)
    {
        super.imageDidLoad(anImage)
        
        let url = CreateTemporaryImageURL()
        if let theImage = anImage,
           let scaledImg = theImage.scaledImage(100)
        {
            do
            {
                try UIImagePNGRepresentation(scaledImg)?.write(to:url)
                self.avaView.image = theImage.circularScaleAndCropImage(frame:self.avaView.bounds)
                self.addButton.setImage(nil, for:.normal)
                self.avaURL = url
            }
            catch let err
            {
                NSLog(err.localizedDescription)
            }
        }
        self.sendButton.isEnabled = self.canPerformLogin()
    }
    
    override var textFields: [UITextField]
    {
        return [self.userNameTextField,
                self.emailTextFiled,
                self.passwordTextFiled]
    }
    
//MARK: -
    func fieldIsValid(aStr:String?, aTextField:UITextField?)
    ->Bool
    {
        var res = false
        if  let theTextField = aTextField,
            let fieldID = DILoginTextFieldRestirationID(rawValue:theTextField.restorationIdentifier!),
            let fieldText = aStr
        {
            switch fieldID
            {
            case .UserNameTextFieldRestorationID,
                 .PasswordTextFieldRestorationID:
                res = fieldText.characters.count > 0
            case .EmailTextFieldRestorationID:
                let nsStr = NSString(string:fieldText)
                let range = nsStr.range(of: "@")
                res = nsStr.length > 0 && range.length + range.location < nsStr.length
            }
        }
        return res
    }

    
    func validateNextButton(didChangeField aTextField:UITextField?, withString aString:String?)
    {
        var res = self.canPerformLogin()
        if res
        {
            [self.userNameTextField, self.passwordTextFiled, self.emailTextFiled].forEach
                {
                    if $0 === aTextField
                    {
                        res = res && self.fieldIsValid(aStr:aString, aTextField:aTextField)
                    }
                    else
                    {
                        res = res && self.fieldIsValid(aStr:$0?.text, aTextField:$0)
                    }
            }
            self.sendButton.isEnabled = res
        }
    }
    
    func canPerformLogin()
    ->Bool
    {
        var res = true
        [self.userNameTextField, self.passwordTextFiled, self.emailTextFiled].forEach
        {
            res = res && self.fieldIsValid(aStr:$0?.text, aTextField:$0)
        }
        res = res && nil != self.avaURL
        self.sendButton.isEnabled = res
        return res

    }
    
//MARK: -
//MARK: Actions
    @IBAction func onAddAva(_ sender: Any)
    {
        self.loadImage()
    }
    
    
    @IBAction func onSend(_ sender: Any)
    {
        if self.canPerformLogin()
        {
            self.onTap(self) // remove keyboard
            self.startWait()
            DINetworkManager.loginWithName(self.userNameTextField.text!, anEmail:self.emailTextFiled.text!, aPassword:self.passwordTextFiled.text!, anImageURL:self.avaURL!, completion:
            { (token:String?) in
                if let theToken = token
                {
                    UserDefaults.standard.set(theToken, forKey:kTokenKey)
                    self.performSegue(withIdentifier:kShowGalerySegueID, sender:sender)
                }
                self.endWait()
            })
        }
    }
    
//MARK: -
//MARK: Keyboard Notifications
    func keyboardWillShow(_ aNotification:Notification)
    {
        self.logoHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ aNotification:Notification)
    {
        self.logoHeightConstraint.constant = CGFloat(self.kDefaultLogoHeight)
        UIView.animate(withDuration: 0.3)
        {
            self.view.layoutIfNeeded()
        }
    }
}

extension DILoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ aTextField: UITextField) -> Bool
    {
        let theID = DILoginTextFieldRestirationID(rawValue:aTextField.restorationIdentifier!)!
        switch theID
        {
            case .UserNameTextFieldRestorationID:
                self.emailTextFiled.becomeFirstResponder()
            case .EmailTextFieldRestorationID:
                self.passwordTextFiled.becomeFirstResponder()
            case .PasswordTextFieldRestorationID:
                aTextField.resignFirstResponder()
                self.onSend(self)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.validateNextButton(didChangeField:textField, withString:textField.text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    -> Bool
    {
        let theNewString = (textField.text as NSString?)?.replacingCharacters(in:range, with:string)
        self.validateNextButton(didChangeField:textField, withString:theNewString)
        return true
    }
}

extension UIImage
{
    func circularScaleAndCropImage(frame aRect:CGRect)
    ->UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(CGSize(width:aRect.size.width, height:aRect.size.height), false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else
        {
            UIGraphicsEndImageContext()
            return nil
        }

        let imageWidth = self.size.width
        let imageHeight = self.size.height
        let rectWidth = aRect.size.width
        let rectHeight = aRect.size.height
        
        let maxImgSide = min(imageWidth, imageHeight)
        let scaleFactorX = rectWidth/maxImgSide
        let scaleFactorY = rectHeight/maxImgSide
        
        let imageCentreX = rectWidth/2
        let imageCentreY = rectHeight/2
        
        let radius = rectWidth/2
        context.beginPath()
        let center = CGPoint(x: imageCentreX, y: imageCentreY)
        context.addArc(center:center, radius:radius, startAngle:0, endAngle:CGFloat(2*Double.pi), clockwise:true)
        context.closePath()
        context.clip()
        context.scaleBy(x: scaleFactorX, y: scaleFactorY)
        
        let theRect = CGRect(x: 0.0, y: 0.0, width: imageWidth, height: imageHeight)
        self.draw(in:theRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// MARK: - UIImage extension
extension UIImage
{
    func scaledImage(_ aSize:CGFloat)
    -> UIImage?
    {
        var w = aSize
        var h = aSize
        if self.size.height > self.size.width && aSize < self.size.width//save ratio
        {
            w = self.size.width * aSize / self.size.height
        }
        else if self.size.height < self.size.width && aSize < self.size.height
        {
            h = self.size.height * aSize / self.size.width
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:w, height:h), false, CGFloat(0))
        self.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width:w, height:h))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

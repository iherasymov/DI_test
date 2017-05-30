//
//  DITapableViewcontroller.swift
//  doit
//
//  Created by Illia on 5/30/17.
//  Copyright © 2017 iherasymov. All rights reserved.
//

import UIKit

protocol DIITapableViewcontroller : class
{
    func onTap(_ sender: Any)
    var textFields:[UITextField] {get}
    var tapGestureRecognizer:UITapGestureRecognizer {get}
}

class DITapableViewcontroller : UIViewController
{
    fileprivate lazy var _tapRecognizer:UITapGestureRecognizer =
    {
        let recognozer = UITapGestureRecognizer(target:self, action:#selector(onTap(_:)))
        return recognozer
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.addGestureRecognizer(self.tapGestureRecognizer)
    }
}

extension DITapableViewcontroller : DIITapableViewcontroller
{
    func onTap(_ sender: Any)
    {
        self.textFields.forEach
        {
            $0.resignFirstResponder()
        }
    }
    
    var textFields:[UITextField]
    {
        return []
    }
    
    var tapGestureRecognizer:UITapGestureRecognizer
    {
        return self._tapRecognizer
    }
}

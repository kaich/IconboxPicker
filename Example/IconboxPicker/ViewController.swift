//
//  ViewController.swift
//  IconboxPicker
//
//  Created by kai on 10/28/2020.
//  Copyright (c) 2020 kai. All rights reserved.
//

import UIKit
import IconboxPicker
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var ivImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickScheme(_ sender: Any) {
        IconboxPicker.shared.pick(keyword: "qq", type: IconboxPickerType.scheme(scheme: "pickerDemo")) { (image) in
            self.ivImage.image = image
        }
    }
    
    @IBAction func clickActivity(_ sender: Any) {
        IconboxPicker.shared.pick(keyword: "qq", type: IconboxPickerType.action(viewController: self)) { (image) in
            self.ivImage.image = image
        }
    }
}


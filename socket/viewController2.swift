//
//  viewController2.swift
//  socket
//
//  Created by IshimotoKiko on 2017/08/07.
//  Copyright © 2017年 IshimotoKiko. All rights reserved.
//

import UIKit

class ViewController2 : UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var roomID: UITextField!
    @IBOutlet weak var IPAddress: UITextField!
    @IBOutlet weak var portNum: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.delegate = self
        self.roomID.delegate = self
        self.IPAddress.delegate = self
        self.portNum.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ViewController
        viewController.name = name.text
        viewController.roomID = roomID.text
        viewController.IPAddress = "http://" + IPAddress.text! + ":" + portNum.text!
    }
}




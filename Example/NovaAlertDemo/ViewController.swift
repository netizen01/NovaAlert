//
//  ViewController.swift
//  NovaAlertDemo
//

import UIKit
import NovaAlert

class ViewController: UIViewController {

    @IBAction func showAlertHandler(sender: UIButton) {
        
        NovaAlert(title: "Demo Alert", message: "This is a test Alert").addAction("Okay", type: .Default) {
            print("Okay Button Pressed")
            
            }.addAction("Sweet", type: .Destructive) {
                print("Sweet Button Pressed")
                
            }.show(true)
    }

}

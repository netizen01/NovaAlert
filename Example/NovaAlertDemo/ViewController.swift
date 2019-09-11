//
//  ViewController.swift
//  NovaAlertDemo
//

import UIKit
import NovaAlert

class ViewController: UIViewController {

    @IBAction func showAlertHandler(_ sender: UIButton) {
        
        NovaAlert(title: "Demo Alert", message: "This is a test Alert").addAction("Okay", type: .default) {
            print("Okay Button Pressed")
            
            }.addAction("Sweet", type: .destructive) {
                print("Sweet Button Pressed")
                
            }.show(true)
    }

}

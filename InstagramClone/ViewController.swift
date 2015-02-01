//
//  ViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/1/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Parse
        Parse.setApplicationId("JAQo5BNVtoi5aKJ7asfrJzonyrbKGrZjCWEMt4yD", clientKey: "STBZzmihMUuWliag8zOz1z0yKm327HyNh9SbGHum")
        
        // The `PFObject` class is a local representation of data persisted to the Parse cloud.
        // Create a class with the name "score"
        var score = PFObject(className: "score")
        
        // Create a property "name" of class "score"
        score.setObject("Rob", forKey: "name")
        score.setObject(23, forKey: "points")
        
        // Save the class into the cloud
        score.saveInBackgroundWithBlock { (success:Bool!, error:NSError!) -> Void in
            if success == true {
                println("Score created with ID: \(score.objectId)")
            } else {
                println(error)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


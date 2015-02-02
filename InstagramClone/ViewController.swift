//
//  ViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/1/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var showImage: UIImageView!
    
    @IBAction func pickImage(sender: UIButton) {
        var imagePicker = UIImagePickerController()
        
        // Image delegate
        imagePicker.delegate = self
        // Image source - Either camera or camera roll
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        // Image editable
        imagePicker.allowsEditing = false
        // Excute this viewController (imagePicker)
        self.presentViewController(imagePicker, animated: true) { () -> Void in
            
        }
        
    }
    
    @IBAction func pauseButtonPressed(sender: UIButton) {
        // Create a spinner
        var activityRect = CGRectMake(0, 0, 50, 50)
        activityIndicator = UIActivityIndicatorView(frame: activityRect)
        
        // Configure the spinner
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // Add spinner view
        view.addSubview(activityIndicator)
        
        // Start animation
        activityIndicator.startAnimating()
        
        // Stop user from interaction with other elements when App is showing the spinner
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    @IBAction func restoreButtonPressed(sender: UIButton) {
        // Stop animation
        activityIndicator.stopAnimating()
        
        // Restore the user interaction
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
    }
    
    @IBAction func createAlertButtonPressed(sender: UIButton) {
        // Create a alert
        var alert = UIAlertController(title: "Hey There!", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        // Configure the alert action
        var alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (myAction) -> Void in
            // Remove the alert message
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(alertAction)
        // Execute/show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Parse
        Parse.setApplicationId("JAQo5BNVtoi5aKJ7asfrJzonyrbKGrZjCWEMt4yD", clientKey: "STBZzmihMUuWliag8zOz1z0yKm327HyNh9SbGHum")
        
        /*
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

        
        // Retrieving data from Parse
        var query = PFQuery(className: "score")
        query.getObjectInBackgroundWithId("mdflwmEREI", block: { (myScore:PFObject!, error:NSError!) -> Void in
            if error == nil {
                println(myScore.objectForKey("name") as NSString)
                println(myScore["points"])
                
                // Updating data on Parse
                myScore["name"] = "James"
                myScore["points"] = 100
                
                // asynchronously save
                myScore.saveInBackgroundWithBlock(nil)
                // synchronously save
                myScore.save()
                
            } else {
                println(error)
            }
        })
        */
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // When image is selected
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // Manually close ViewControll after selecting the picture
        self.dismissViewControllerAnimated(true, completion: nil)
        // Show the picture in the imageView
        showImage.image = image
    }
}


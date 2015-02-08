//
//  ViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/1/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

enum Status {
    case signUp
    case login
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var currentStatus = Status.signUp
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var alreadyRegisteredLabel: UILabel!
    
    @IBOutlet weak var loginButtonLabel: UIButton!
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        if currentStatus == Status.signUp {
            // When switch to login screen
            currentStatus = Status.login
            signUpLabel.text = "Use the form below to login"
            signUpButtonLabel.setTitle("Log In", forState: UIControlState.Normal)
            alreadyRegisteredLabel.text = "Not registered?"
            loginButtonLabel.setTitle("Sign Up", forState: UIControlState.Normal)
        } else {
            // When switch to signUp screen
            currentStatus = Status.signUp
            signUpLabel.text = "Use the form below to sign up"
            signUpButtonLabel.setTitle("Sign Up", forState: UIControlState.Normal)
            alreadyRegisteredLabel.text = "Already registered?"
            loginButtonLabel.setTitle("Log In", forState: UIControlState.Normal)
        }
    }
    
    @IBOutlet weak var signUpButtonLabel: UIButton!
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        var error = ""
        
        if username.text == "" || password.text == "" {
            error = "Please enter username and password"
        }
        
        if error != "" {
            displayAlert(title: "Error in Form", error: error)
        } else {
            // Parse codes - Obtain user information
            var user = PFUser()
            user.username = username.text
            user.password = password.text
            
            // Add spinner animation for showing verification delay
            var activityRect = CGRectMake(0, 0, 50, 50)
            activityIndicator = UIActivityIndicatorView(frame: activityRect)
            
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if currentStatus == Status.signUp {
                
                // Parse codes - user sign up
                user.signUpInBackgroundWithBlock({ (signUpSucceeded:Bool!, signUpError:NSError!) -> Void in
                    // Stop spinner animation after verification
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signUpError == nil {
                        // Good signup
                        println("Yesh Signed up")
                    } else {
                        if let errorString = signUpError.userInfo?["error"] as? NSString {
                            error = errorString
                        } else {
                            error = "Somehing else is wrong..."
                        }
                        self.displayAlert(title: "Could not sign up", error: error)
                    }
                })
                
            } else {
                
                // Parse codes - user login
                PFUser.logInWithUsernameInBackground(user.username, password: user.password, block: { (logInUser:PFUser!, logInError:NSError!) -> Void in
                    // Stop spinner animation after verification
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if logInUser != nil {
                        // Good login
                        println("Yesh logged in")
                    } else {
                        if let errorString = logInError.userInfo?["error"] as? NSString {
                            error = errorString
                        } else {
                            error = "Somehing else is wrong..."
                        }
                        self.displayAlert(title: "Could not log in", error: error)
                    }
                })
                
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Gets the currently logged in user from disk and returns an instance of it.
        // - signed in informaiton is saved on Parse
        // - signed in information is retrieved every time the view is loaded
        println(PFUser.currentUser())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Customize Alert message
    func displayAlert(#title:String, error:String) {
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        var alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (myAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
        }
    }
}


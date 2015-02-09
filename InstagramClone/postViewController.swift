//
//  postViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/8/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class postViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imageSelected:Bool = false
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBAction func chooseImageButtonPressed(sender: UIButton) {
        
        var imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageController.allowsEditing = false
        
        self.presentViewController(imageController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var shareText: UITextField!
    
    @IBAction func postImageButtonPressed(sender: UIButton) {
        
        var error:String = ""
        
        if !imageSelected {
            error = "Please select an image"
        }
        
        if shareText.text == "" {
            error = "Please enter a message"
        }
        
        if error != "" {
            displayAlert(title: "ERROR", error: error)
        } else {
            // Add spiner for activity indication
            var activityRect = CGRectMake(0, 0, 50, 50)
            activityIndicator = UIActivityIndicatorView(frame: activityRect)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post = PFObject(className: "Post")
            post["title"] = shareText.text
            post["username"] = PFUser.currentUser().username
            
            // Save post text on the Parse server
            post.saveInBackgroundWithBlock({ (saveTextSuccess:Bool!, saveTextError:NSError!) -> Void in
                if saveTextSuccess == false {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    self.displayAlert(title: "Error", error: saveTextError.localizedDescription)
                } else {
                    // Return image data for the specified image in PNG format
                    let imageData = UIImagePNGRepresentation(self.imageToPost.image)
                    // `PFFile` representes a file of binary data stored on the Parse servers
                    let imageFile = PFFile(name: "image.png", data: imageData)
                    // Save image data in the post
                    post["imageFile"] = imageFile
                    
                    // Save image data on the Parse server
                    post.saveInBackgroundWithBlock({ (saveImageSuccess:Bool!, saveImageError:NSError!) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if saveImageSuccess == false {
                            self.displayAlert(title: "Eroor", error: saveImageError.localizedDescription)
                        } else {
                            self.displayAlert(title: "Sucess", error: "Image has been posted successfully")
                        }
                        
                        // Initialization
                        self.initializeView()
                    })
                    
                }
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
        imageSelected = true
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
    
    // Initlization
    func initializeView() {
        imageSelected = false
        imageToPost.image = UIImage(named: "Blank_woman_placeholder")
        shareText.text = ""
    }

}

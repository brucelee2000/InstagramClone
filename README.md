# InstagramClone
Parse setup and initialization
------------------------------
* **Step 1. Install Parse iOS SDK**
    
    Download from Parse website and drag it into project
    
* **Step 2. Initialize Parse in *AppDelegate* file**

        // Initialize Parse
        Parse.setApplicationId("JAQo5BNVtoi5aKJ7asfrJzonyrbKGrZjCWEMt4yD", clientKey: "STBZzmihMUuWliag8zOz1z0yKm327HyNh9SbGHum")
        
Parse class creation and save
-----------------------------
* **Class and its memeber creation**

        // The `PFObject` class is a local representation of data persisted to the Parse cloud.
        // Create a class with the name "score"
        var score = PFObject(className: "score")
        
        // Create a property "name" of class "score"
        score.setObject("Rob", forKey: "name")
        score.setObject(23, forKey: "points")
        
* **Save data onto Parse**

    *save()* **synchronously** saves data onto Parse and takes long time if data is large
    
    *saveInBackgroundWithBlock()* **asynchronously** saves data onto Parse

        // Save the class into the cloud
        score.saveInBackgroundWithBlock { (success:Bool!, error:NSError!) -> Void in
            if success == true {
                println("Score created with ID: \(score.objectId)")
            } else {
                println(error)
            }
        }
      
Parse data modification and retrieving
-------------------------------------
* **Retrieve data by its ID with *getObjectInBackgroundWithId()* from Parse**

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

Obtain images from Photo library or Camera
------------------------------------------
* **Step 0. Add required protocals (*UINavigationControllerDelegate, UIImagePickerControllerDelegate*) to VC**

* **Step 1. Pick an image**

        class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
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
            ...
        }    

* **Step 2. Action after selecting image**

        // When image is selected
        func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
            // Manually close ViewControll after selecting the picture
            self.dismissViewControllerAnimated(true, completion: nil)
            // Show the picture in the imageView
            showImage.image = image
        }
        
Spinner Usage
-------------
Spinner is used to simulate loading/reading/time consuming work

* **Step 1. Create and configure the spinner**

        // Create a spinner
        var activityRect = CGRectMake(0, 0, 50, 50)
        activityIndicator = UIActivityIndicatorView(frame: activityRect)
        
        // Configure the spinner
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
* **Step 2. Add spinner to the VC**

        // Add spinner view
        view.addSubview(activityIndicator)
        
* **Step 3. Start animation and pause user interaction**

        // Start animation
        activityIndicator.startAnimating()
        
        // Stop user from interaction with other elements when App is showing the spinner
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
* **Step 4. Stop animation and resume user interaction**

        // Stop animation
        activityIndicator.stopAnimating()
        
        // Restore the user interaction
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        


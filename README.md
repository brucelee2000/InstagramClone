# InstagramClone
Parse setup and initialization
------------------------------
Details are here http://codewithchris.com/using-parse-swift-xcode-6/
* **Step 1. Install Parse iOS SDK**
    
    Download from Parse website and drag it into project
    * Parse.framework
    * Bolts.framework

    Link other required framework/library
    * AudioToolbox.framework
    * CFNetwork.framework
    * CoreGraphics.framework
    * CoreLocation.framework
    * libz.dylib
    * MobileCoreServices.framework
    * QuartzCore.framework
    * Security.framework
    * StoreKit.framework
    * SystemConfiguration.framework
    * libsqlite3.dylib
    
* **Step 2. Import Parse into Swift with bridging header**
    
    * Create a new File (File -> New -> File) of type Objective-C File.
    
    * It will prompt you if you would like to configure an Obj-C Bridging Header. Click “Yes"
    
    * Delete generated .m file and keep generated .h file
    
    * Add this code to the YourProjectName-Bridging-Header.h
    
            #import <Parse/Parse.h>
    
* **Step 3. Initialize Parse in *AppDelegate* file**

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
      
Parse Retrieves General Data and Modifications
----------------------------------------------
Find objects with certian condition by *findObjectsInBackgroundWithBlock()*

* **Step 1. Create a query**

        // Create a user query
        var query = PFUser.query()
        
* **Step 2. Setup filters by *whereKey()*.**      

        query.whereKey("follower", equalTo: PFUser.currentUser().username)
        query.whereKey("following", equalTo: user.username)
        
* **Step 3. Limite the number of results after query is run**

        // Limit what could be lots of points
        query.limit = 10
                    
* **Step 4. Excute the query**

        // Construct user array with the query
        query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
            self.users.removeAll(keepCapacity: true)
            self.following.removeAll(keepCapacity: true)
            ...
        })
            
* **Step 5. Process the results from query one by one**            
            
            ...
            for object in objects {
                var user:PFUser = object as PFUser
                var isFollowing:Bool
                if user.username != PFUser.currentUser().username {
                   ...
                }
                ...
            }
            ...
* **Overall example**

        // Create a user query
        var query = PFUser.query()
        // Construct user array with the query
        query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
            self.users.removeAll(keepCapacity: true)
            self.following.removeAll(keepCapacity: true)
            
            for object in objects {
                var user:PFUser = object as PFUser
                var isFollowing:Bool
                if user.username != PFUser.currentUser().username {
                   
                    isFollowing = false
                    
                    // Query follower/following relationship from the class "followers" in Parse
                    var query = PFQuery(className: "followers")
                    query.whereKey("follower", equalTo: PFUser.currentUser().username)
                    query.whereKey("following", equalTo: user.username)
                    query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
                        if error == nil {
                            // The query is successful
                            for object in objects {
                                isFollowing = true
                            }
                        } else {
                            println(error)
                        }
                        self.users.append(user.username)
                        self.following.append(isFollowing)
                        self.tableView.reloadData()
                        
                        // Stop pull to refresh animation
                        self.refresher.endRefreshing()
                    })
                }
            }
        })

Parse Retrieves Specific Data and Modificatoin
----------------------------------------------
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

Parse Image Data Saving
-----------------------
* **Method 1: directly uploading UIImage as NSData to Parse (size limitation is 128K)**

        var post = PFObject(className: "Post")
        post["title"] = shareText.text
        post["username"] = PFUser.currentUser().username
        
        // Return image NSData for the specified image in PNG format
        let imageData = UIImagePNGRepresentation(self.imageToPost.image)
        
        // Save image data in the post
        post["image"] = imageData
        
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

* **Method 2: Upload image as NSData in a binary file by *PFFile()*.**

        var post = PFObject(className: "Post")
        post["title"] = shareText.text
        post["username"] = PFUser.currentUser().username
        
        // Return image NSData for the specified image in PNG format
        let imageData = UIImagePNGRepresentation(self.imageToPost.image)
        // let imageData = UIImageJPEGRepresentation(self.imageToPost.image, 0.5)           // 3G connection may be 0.01 to lower uploaded image size
        
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
        

Parse Retrieves and Shows Image Data
------------------------------------
* **Step 0. Query and retrieve image data**

        var queryFollowingUsers = PFQuery(className: "followers")
        queryFollowingUsers.whereKey("follower", equalTo: PFUser.currentUser().username)
        
        queryFollowingUsers.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                
                for object in objects {
                    let followingUser = object["following"] as String
                    
                    // Create Parse query to download all required data
                    var query = PFQuery(className: "Post")
                    query.whereKey("username", equalTo: followingUser)
                    query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
                        if error == nil {
                            // Query successfully
                            println("Retrievd \(objects.count) posts")
                            
                            for object in objects {
                                self.postedTitles.append(object["title"] as String)
                                self.postedUsers.append(object["username"] as String)
                                
                                // Note: Parse does not download actual image content by default
                                self.postedImageFiles.append(object["imageFile"] as PFFile)
                                
                                // Reload data after finish downloading
                                self.tableView.reloadData()
                            }
                        } else {
                            // Query failed
                            println(error)            
                        }
                    }
                }
            } else {
                println(error)
            }
        }
        
* **Step 1. Show retrieved image data in real time**

        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let myFeedCell = tableView.dequeueReusableCellWithIdentifier("myFeedCell", forIndexPath: indexPath) as FeedTableViewCell
            
            // Configure the cell...
            myFeedCell.postedTitle.text = postedTitles[indexPath.row]
            myFeedCell.postedUser.text = postedUsers[indexPath.row]
            
            // Retrieve image from Parse in real time
            postedImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData!, error:NSError!) -> Void in
                if error == nil {
                    // Retrieve image OK
                    let image = UIImage(data: imageData)
                    myFeedCell.postedImage.image = image
                }
            }
            
            return myFeedCell
        }

Parse User Sign-up, Log-in, and Log-out
---------------------------------------
* **Step 0. Obtain username and password**

        // Parse codes - Obtain user information
        var user = PFUser()
        user.username = username.text
        user.password = password.text
        
* **Step 1. Sign-up or Log-in**

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
        
* **Step 2. Logout**

        @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
            // Logout current user
            PFUser.logOut()
            
            // Go back to initial VC
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }


Parse Check User Login Status
-----------------------------
        // Gets the currently logged in user from disk and returns an instance of it.
        // - signed in informaiton is saved on Parse
        // - signed in information is retrieved every time the view is loaded
        println(PFUser.currentUser())
    
        override func viewDidAppear(animated: Bool) {
            if PFUser.currentUser() != nil {
                self.performSegueWithIdentifier("jumpToUserTable", sender: self)
            }
        }        

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

Table Cell Accessory Type
-------------------------
Types: Checkmark/None/Disclosure/Detail Disclosure...

+ **Disclosure**: just an indicator and no response/action when tapping it

+ **Detail disclosure**: action is associated with tapping on it

+ **Checkmark**: just an indicator

* **Step 1. Show accessory of the cell**

        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell
    
            // Configure the cell...
            cell.textLabel?.text = users[indexPath.row]
            
            if following[indexPath.row] {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            
            return cell
        }   
    
* **Step 2. Action when electing the cell**

        // Change accessory type when selecting the cell
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            // Create a tick for each row
            let cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                cell.accessoryType = UITableViewCellAccessoryType.None
                // Submit deselct follower/following relationship to the class "followers" in Parse
                var query = PFQuery(className: "followers")
                query.whereKey("follower", equalTo: PFUser.currentUser().username)
                query.whereKey("following", equalTo: cell.textLabel?.text)
                query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        // The query is successful and delete target row in Parse
                        for object in objects {
                            object.deleteInBackgroundWithBlock(nil)
                        }
                    } else {
                        println(error)
                    }
                })
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                // Submit new follower/following relationship to the class "followers" in Parse
                var following = PFObject(className: "followers")
                following["following"] = cell.textLabel?.text
                following["follower"] = PFUser.currentUser().username
                following.saveInBackgroundWithBlock(nil)
            }
        }
        
* **Step 3. Action when tapping cell detail discloure**

        // Call in-app email client when tapping cell detail disclosure
        override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
            indexPathForTapped = indexPath
            performSegueWithIdentifier("sendMail", sender: self)
        }

        
Pull to Refresh Function
------------------------
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ...
        // Customize the showing message when pull to refresh
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh WORDS!")
        
        // Adds a target and action for a particular event (or events) to an internal dispatch table.
        refresher.addTarget(self, action: "refreshAction", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add refresher as subview to current VC
        self.tableView.addSubview(refresher)
    }    

    // Function to be excuted for 'Pull to refresh"
    func refreshAction() {
        println("Refresh function is called")
        updateUsers()
    }
    
    

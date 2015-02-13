//
//  feedTableViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/10/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class feedTableViewController: UITableViewController {
    
    var postedTitles:[String] = []
    var postedUsers:[String] = []
    var postedImages:[UIImage] = []
    var postedImageFiles:[PFFile] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                            println(error)            }
                    }
                    
                    
                }
                
            } else {
                println(error)
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return postedTitles.count
    }

    
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
    
    // Make cell height as fixed value otherwise one cell occupies on screen
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

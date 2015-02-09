//
//  userTableViewController.swift
//  InstagramClone
//
//  Created by Yosemite on 2/7/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class userTableViewController: UITableViewController {
    
    var users:[String] = []
    var following:[Bool] = []
    
    var refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // Update user table and relatioship
        updateUsers()
        
        // Customize the showing message when pull to refresh
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh WORDS!")
        // Adds a target and action for a particular event (or events) to an internal dispatch table.
        refresher.addTarget(self, action: "refreshAction", forControlEvents: UIControlEvents.ValueChanged)
        // Add refresher as subview to current VC
        self.tableView.addSubview(refresher)
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
        return users.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = users[indexPath.row]
        
        if (!following.isEmpty) {
            if following.count > indexPath.row {
                if following[indexPath.row] {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            }
        }
        
        return cell
    }
    
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
    
    func updateUsers() {
        // Create a user query
        var query = PFUser.query()
        // Construct user array with the query
        query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error:NSError!) -> Void in
            self.users.removeAll(keepCapacity: true)
            for object in objects {
                var user:PFUser = object as PFUser
                var isFollowing:Bool
                if user.username != PFUser.currentUser().username {
                    self.users.append(user.username)
                    
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
                        self.following.append(isFollowing)
                        self.tableView.reloadData()
                        
                        // Stop pull to refresh animation
                        self.refresher.endRefreshing()
                    })
                }
                
                
            }
            //self.tableView.reloadData()
        })

    }
    
    // Function to be excuted for 'Pull to refresh"
    func refreshAction() {
        println("Refresh function is called")
        updateUsers()
    }
}

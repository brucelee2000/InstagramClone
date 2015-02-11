//
//  FeedTableViewCell.swift
//  InstagramClone
//
//  Created by Yosemite on 2/10/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postedImage: UIImageView!
    
    @IBOutlet weak var postedTitle: UILabel!
    
    @IBOutlet weak var postedUser: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

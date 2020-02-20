//
//  PostCell.swift
//  Parstagram
//
//  Created by Shafer Hess on 2/19/20.
//  Copyright © 2020 Shafer Hess. All rights reserved.
//

import Parse
import UIKit

class PostCell: UITableViewCell {
    
    // Cell Outlets
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var postView: UIImageView!
    
    var objectId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let query = PFQuery(className: "Posts")
        query.whereKey("objectId", equalTo: self.objectId)
        
        query.findObjectsInBackground { (posts: [PFObject]?, error) in
            for post in posts! {
                post.deleteEventually()
            }
        }
    }
}

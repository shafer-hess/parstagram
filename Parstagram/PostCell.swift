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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var postView: UIImageView!
    
    var objectId: String = ""
    weak var deleteDelegate: DeleteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onDelete(_ sender: Any) {
        deleteDelegate?.deletePost(objectId: self.objectId)
    }
}

//
//  CommentCell.swift
//  Parstagram
//
//  Created by Shafer Hess on 2/24/20.
//  Copyright © 2020 Shafer Hess. All rights reserved.
//

import AlamofireImage
import Parse
import UIKit

class CommentCell: UITableViewCell {
    // CommentCell Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

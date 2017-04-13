//
//  upNextListTableViewCell.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/9/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

class upNextListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

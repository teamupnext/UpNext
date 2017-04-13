//
//  TableViewCell.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/7/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var CoverImage: UIImageView!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Song: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

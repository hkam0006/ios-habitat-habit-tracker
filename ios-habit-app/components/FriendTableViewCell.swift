//
//  FriendTableViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 28/5/2023.
//

import UIKit
/**
 A subclass of `UITableViewCell` that represents a cell that contains information such as friend name which is contained in `nameLabel` and friend email which is stored in `emailLabel`.
 
 This class is utilised in the `ManageFriendsViewController`'s table view.
 */
class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

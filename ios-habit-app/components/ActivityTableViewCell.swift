//
//  ActivityTableViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 28/5/2023.
//

import UIKit
/**
 A class that represents a activity cell within the `SocialViewController`. Each cell has a `UILabel` that desribes friend's activity.
 */
class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var activityMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

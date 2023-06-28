//
//  FriendRequestTableViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 3/6/2023.
//

import UIKit
/**
 A subclass of `UITableViewCell` that represents a friend request cell. The cell contains information about the friend request such as the request sender contained in `userNameLabel`, request sender's email address contained in the `emailLabel`. Each cell also has a decline abd accept button that the user can interact with.
 
 This class is utilised in the `ManageFriendsViewController`'s table view. Each cell has a `ManageFriendsViewController` delegate for performing actions such as accepting and declining friend requests.
 */
class FriendRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var friend: Friend?
    var delegate: ManageFriendsViewController?
    @IBOutlet weak var declineButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Changing the tint colour of the decline button
        declineButton.tintColor = UIColor.systemRed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Method is called when declineButton is pressed.
    @IBAction func declineButtonPressed(_ sender: Any) {
        guard let delegate, let friend else {
            return
        }
        delegate.declineFriendRequest(friend: friend)
    }
    
    // Method is called when accept button is pressed.
    @IBAction func acceptButtonPressed(_ sender: Any) {
        guard let delegate, let friend else {
            return
        }
        delegate.acceptFriendRequest(friend: friend)
    }
}

//
//  CategoryCollectionViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 29/4/2023.
//

import UIKit

/**
 Class that represents a habit category/label that subclass of `UICollectionViewCell`. It has a `categoryNameLabel` which is the name of the label displayed to the user.
 */
class CategoryCollectionViewCell: UICollectionViewCell {
    let identifier = "labelCell"
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    

}

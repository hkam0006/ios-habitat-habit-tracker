//
//  IconCollectionViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 23/4/2023.
//

import UIKit

private let emojis = [
    "🏀","⚽️", "🏈" ,"⚾️", "🧘🏼‍♂️","🚴🏼‍♂️","🎤","🎮", "🥏", "🏋🏻‍♀️", "📚", "🎹", "🏃🏻‍♀️", "🤸🏼", "🏊🏼‍♀️","🛏", "🍎", "📱" , "⛳️", "🥊", "🎭", "🎨", "🎸", "💻"
]
private let CELL_ICON = "iconCell"

class IconCollectionViewController: UICollectionViewController {
    var delegate: IconDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UICollectionViewDataSource
    
    // Number of sections in the collection view
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The number of rows each section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    // Set up collection view cells.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ICON, for: indexPath as IndexPath) as! IconCollectionViewCell
        // Configure the cell
        cell.emojiLabel.text = emojis[indexPath.row]
        return cell
    }
    
    // Handle when cell selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIcon = emojis[indexPath.row]
        guard var delegate else {
            return
        }
        delegate.updateIcon(selectedIcon)
        delegate.iconChosen = true
        delegate.toggleSaveButton()
        navigationController?.popViewController(animated: true)
    }

}

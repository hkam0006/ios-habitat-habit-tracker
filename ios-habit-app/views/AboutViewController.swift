//
//  AboutViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 4/6/2023.
//

import UIKit

/**
 View controller for about section
 */
class AboutViewController: UIViewController {
    // Text view for acknowledements
    @IBOutlet weak var textView: UITextView!
    
    // Handle set up when view controller loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Changing text colour of text view
        textView.textColor = UIColor.label
    }
}

//
//  ProgressBarUIView.swift
//  ios-habit-app
//
//  Created by Soodles . on 29/4/2023.
//

import UIKit
/**
 A custom UIView that represents a progress bar.
 
 The `ProgressBarUIView` class provides a customizable progress bar view that can be used to visually represent progress or completion of habits. It supports customization of the progress color and progress value.
*/
class ProgressBarUIView: UIView {
    // The colour of the progress bar, `update()` method called everytime this value is altered.
    var color: UIColor = .green {
        didSet { update() }
    }
    
    // The progress bar float value, `update()` method called everytime this value is altered.
    var progress: CGFloat = 0 {
        didSet { update() }
    }
    
    // Represents the progress of the progress bar.
    private let progressLayer = CALayer()
    
    // Represents the mask on the view's layer, which clips the contents of the view to a specified shape.
    private let backgroundMask = CAShapeLayer()
    
    // MARK: - Initialisation
    
    /**
     Initialises a new progress bar with a provided frame.
     
     - Parameters:
        - frame: The frame rectangle for the view.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    /**
     Initialises a new progress bar from a storyboard or nib file.
     
     - Parameters:
        - coder: The object that decodes nib files or storyboard-based data.

     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // Adding the sublayer to layer's hierarchy
    private func setupLayers() {
        layer.addSublayer(progressLayer)
    }
    
    // Layout of subviews, called automatically when layout of view's subviews need to be updated.
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundMask.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.height * 0.25).cgPath
        layer.mask = backgroundMask
        update()
    }
    
    /**
     Updates the appearance of the progress bar based on the current progress float value and the colour attributes.
     
     This mehod calculates the frame for the `progressLayer` based on the current progress value, sets its background color to the current color, and sets its corner radius to 3. 
     */
    func update() {
        let progressRect = CGRect(origin: .zero, size: CGSize(width: self.bounds.size.width * progress, height: self.bounds.size.height))
        self.progressLayer.frame = progressRect
        self.progressLayer.backgroundColor = self.color.cgColor
        self.progressLayer.cornerRadius = 3
    }

}

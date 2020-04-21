//
//  Spinner.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

class Spinner {
    let superView: UIView
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(onView superView: UIView) {
        self.superView = superView
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        superView.bringSubviewToFront(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        superView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        superView.addConstraint(horizontalConstraint)

        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        superView.addConstraint(verticalConstraint)
    }
    
    func start() {
        superView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    func stop() {
        superView.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
}

//
//  SplashScreenAnimationView.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import UIKit

class SplashScreenAnimationView: UIView {
    fileprivate let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "loading-animation.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: -1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        backgroundColor = .white
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func startGif() {
        logoGifImageView.startAnimatingGif()
    }
    
    func stopGif() {
        logoGifImageView.stopAnimatingGif()
    }
}

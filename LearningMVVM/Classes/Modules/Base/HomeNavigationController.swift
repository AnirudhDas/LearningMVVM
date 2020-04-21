//
//  HomeNavigationController.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

class HomeNavigationController: UINavigationController {
    fileprivate let homeVC: HomeVC
    
    init(rootViewController homeVC: HomeVC) {
        self.homeVC = homeVC
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [homeVC]
        
        self.tabBarItem?.image = UIImage(systemName: "house")
        self.tabBarItem?.selectedImage = UIImage(systemName: "house.fill")
        self.tabBarItem?.title = TabBarTitle.home.rawValue
        self.navigationBar.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
}

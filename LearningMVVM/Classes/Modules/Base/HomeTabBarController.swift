//
//  HomeTabBarController.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

enum TabBarTitle: String {
    case home = "Home"
    case account = "My Account"
}

class HomeTabBarController: UITabBarController {
    fileprivate let homeNavigationController: HomeNavigationController
    fileprivate let accountNavigationController: AccountNavigationController
    
    init(homeNavigationController: HomeNavigationController,
         accountNavigationController: AccountNavigationController) {
        self.homeNavigationController = homeNavigationController
        self.accountNavigationController = accountNavigationController
        
        super.init(nibName: nil, bundle: nil)
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.delegate = self
        
        setupTabBar()
    }
    
    fileprivate func setupTabBar() {
        setupTabBarAppearance()
        setTabBarViewControllers()
    }
       
    fileprivate func setTabBarViewControllers() {
        self.setViewControllers([homeNavigationController, accountNavigationController], animated: false)
        self.selectedIndex = 0
    }
   
    fileprivate func setupTabBarAppearance () {
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.tintColor = UIColor.colorWithHex(0xd84e55)
        self.tabBar.selectedItem?.setTitleTextAttributes([.foregroundColor: UIColor.colorWithHex(0xd84e55)], for: .selected)
        self.tabBar.selectedItem?.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }
}

extension HomeTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}

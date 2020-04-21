//
//  AccountNavigationController.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

class AccountNavigationController: UINavigationController {
    fileprivate let accountVC: AccountVC
    
    init(rootViewController accountVC: AccountVC) {
        self.accountVC = accountVC
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [accountVC]
        
        self.tabBarItem?.image = UIImage(systemName: "person")
        self.tabBarItem?.selectedImage = UIImage(systemName: "person.fill")
        self.tabBarItem?.title = TabBarTitle.account.rawValue
        self.navigationBar.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
}

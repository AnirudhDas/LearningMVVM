//
//  BaseVC.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    var hidesNavBar: Bool = false
    var originalHiddenState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hidesNavBar, let originalHiddenState = self.navigationController?.navigationBar.isHidden {
            self.originalHiddenState = originalHiddenState
            self.navigationController?.navigationBar.isHidden = hidesNavBar
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hidesNavBar {
            self.navigationController?.navigationBar.isHidden = self.originalHiddenState
        }
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 18.0, weight: .semibold)]
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.backgroundColor = UIColor.lightGray
    }
    
    func changeStatusBarColor() {
        
    }
}

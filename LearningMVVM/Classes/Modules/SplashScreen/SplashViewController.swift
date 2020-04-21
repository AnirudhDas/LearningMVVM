//
//  SplashViewController.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var gifAnimationView: SplashScreenAnimationView!
    
    /*
    fileprivate lazy var spinner: Spinner = {
        return Spinner(onView: self.view)
    }()
    */
    
    fileprivate let homeTabBarController: HomeTabBarController
    fileprivate let configService: ConfigServiceProtocol
    
    init(configService: ConfigServiceProtocol, homeTabBarController: HomeTabBarController) {
        self.configService = configService
        self.homeTabBarController = homeTabBarController
        super.init(nibName: "SplashViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCountryConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gifAnimationView.startGif()
    }
    
    fileprivate func getCountryConfig() {
        configService.getCountryConfig { [weak self] (country) in
            self?.gifAnimationView.stopGif()
            if country == "IND" {
                self?.loadTabBarVC()
            }
        }
    }
    
    fileprivate func loadTabBarVC() {
        homeTabBarController.modalPresentationStyle = .fullScreen
        self.present(homeTabBarController, animated: false) {
            self.dispatchPendingTasks()
        }
    }
    
    fileprivate func dispatchPendingTasks() {
        
    }
}

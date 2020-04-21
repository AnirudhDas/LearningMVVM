//
//  AppDelegate.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 11/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    final let container = ServiceLocatorContainer.defaultContainer()
    var window: UIWindow?
    
    internal func splashRootViewController() -> UIViewController {
        return container.resolve(SplashViewController.self)
    }
    
    /*
    internal func navigationRootViewController() -> UIViewController {
        return container.resolve(HomeNavigationController.self)
    }
    */
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ServiceConfigurationManager.initializeEndPointsForEnv()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = splashRootViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

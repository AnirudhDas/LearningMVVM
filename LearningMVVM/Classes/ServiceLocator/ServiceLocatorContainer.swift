//
//  ServiceLocatorContainer.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 11/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import UIKit

//MARK: SERVICE LOCATOR - Registers all services. And resolves it.

// **Example to register:**
///
///     let container = Container()
///     container.register(Protocol1.self) { _ in ImplementationClass1() }
///     container.register(Protocol2.self) { resolver in ImplementationClass2(val: resolver.resolve(Protocol1.self)!) }
///
/// **Example to retrieve:**
///
///     let x = container.resolve(Protocol2.self)!

class ServiceLocatorContainer {
    static func defaultContainer() -> Container {
        let container = Container()
        
        container.register(SessionManaging.self) { _ in
            return SessionManager()
        }
        
        container.register(AlamofireManager.self) { r in
            return AlamofireManager(sessionManager: r.resolve(SessionManager.self))
        }
        
        container.register(ConfigServiceProtocol.self) { _ in
            return ConfigService()
        }
        
        container.register(HomeVC.self) { _ in
            return HomeVC()
        }
        
        container.register(HomeNavigationController.self) { r in
            return HomeNavigationController(rootViewController: r.resolve(HomeVC.self))
        }
        
        container.register(AccountVC.self) { _ in
            return AccountVC()
        }
        
        container.register(AccountNavigationController.self) { r in
            return AccountNavigationController(rootViewController: r.resolve(AccountVC.self))
        }
        
        container.register(HomeTabBarController.self) { r in
            return HomeTabBarController(homeNavigationController: r.resolve(HomeNavigationController.self),
                                        accountNavigationController: r.resolve(AccountNavigationController.self))
        }
        
        container.register(SplashViewController.self) { r in
            return SplashViewController(configService: r.resolve(ConfigServiceProtocol.self),
                                        homeTabBarController: r.resolve(HomeTabBarController.self))
        }
        
        return container
    }
}

//
//  ConfigService.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 12/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

protocol ConfigServiceProtocol {
    func getCountryConfig(completion: @escaping (String) -> Void)
}

class ConfigService: ConfigServiceProtocol {
    func getCountryConfig(completion: @escaping (String) -> Void) {
        performUIUpdatesOnMainAfterDelay(delayTime: 5) {
            completion("IND")
        }
    }
}

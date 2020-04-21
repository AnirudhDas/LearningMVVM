//
//  DataExtension.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

extension Data {
    func dataToJSON() -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
        } catch {}
        return nil
    }
}

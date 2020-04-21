//
//  StringExtension.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 20/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localizedWith(_ args: String...) -> String {
        return NSString(format: self.localized() as NSString, args) as String
    }
}

//
//  UserDefaultsExtension.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

extension UserDefaults {
    /**
     Method to save a key value pair in UserDefaults.
     */
    public class func saveValueForKey(value: Any, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }

    /**
     Method to retrive a key value pair from UserDefaults.
     */
    public class func getValueForKey(forKey: String) -> Any? {
        return UserDefaults.standard.value(forKey: forKey) as Any?
    }

    /**
     Method to delete a key value pair from UserDefaults.
     */
    public class func deleteValueForKey(forKey: String) {
        UserDefaults.standard.removeObject(forKey: forKey)
        UserDefaults.standard.synchronize()
    }
}

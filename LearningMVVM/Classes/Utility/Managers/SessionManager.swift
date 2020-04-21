//
//  SessionManager.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

protocol SessionManaging {
    func isActive() -> Bool
    func getToken() -> String
    func saveToken(_ authToken: String)
    func deleteToken()
    func deleteUserData()
}

class SessionManager: SessionManaging {
    func isActive() -> Bool {
       return !getToken().isEmpty
    }
    
    func getToken() -> String {
        return UserDefaults.getValueForKey(forKey: "AUTH_TOKEN") as? String ?? ""
    }
    
    func saveToken(_ authToken: String) {
        UserDefaults.saveValueForKey(value: authToken, forKey: "AUTH_TOKEN")
    }
    
    func deleteToken() {
        UserDefaults.deleteValueForKey(forKey: "AUTH_TOKEN")
    }
    
    func deleteUserData() {
        deleteToken()
    }
}

//
//  APIError.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 19/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

struct APIError: Decodable {
    let code: String
    let message: String
    let detailedMessage: String
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case message = "Message"
        case detailedMessage = "DetailedMessage"
    }
}

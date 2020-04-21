//
//  AlamofireManager.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 12/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireManager {
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    func request(_ urlRequestConvertible: URLRequestConvertible, completionHandler: @escaping (APIError?, DataRequest, Int) -> Void) -> DataRequest {
        return AF.request(urlRequestConvertible).printAPIDebugInfo().validateResponse(sessionManager).checkForAPIError(completionHandler: completionHandler)
    }
}

extension DataRequest {
    func printAPIDebugInfo() -> Self {
        return self.response { response in
            
            //API Debug Info
            if let urlString = response.request?.url {
                print("URL: \(urlString)")
            }
            
            if let headers = response.request?.allHTTPHeaderFields {
                print("Headers: \(headers)")
            }
            
            if let urlrequest = response.request?.urlRequest, let httpBody = urlrequest.httpBody, let requestBody = httpBody.dataToJSON() {
                print("RequestBody: \(requestBody)")
            }
            
            if let httpMethod = response.request?.httpMethod {
                print("HTTP Method: \(httpMethod)")
            }
            
            if let statusCode = response.response?.statusCode {
                print("HTTP Status: \(statusCode)")
            }
            
            if let responseData = response.data, let responseJson = responseData.dataToJSON() {
                print("Response: \(responseJson)")
            }
        }
    }
    
    func validateResponse(_ sessionManager: SessionManager) -> Self {
        return self.response { response in
            if let statusCode = response.response?.statusCode {
                if statusCode == 401 {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AUTH_FAILURE_NOTIFICATION"), object: nil)
                } else if let dict = response.response?.allHeaderFields, let authToken = dict["Authtoken"] as? String {
                    sessionManager.saveToken(authToken)
                } else if let statusCode = response.response?.statusCode, case 200..<300 = statusCode {
                    //Valid response
                }
            }
        }
    }
    
    func checkForAPIError(completionHandler: @escaping (APIError?, DataRequest, Int) -> Void) -> Self {
        return self.responseDecodable(of: APIError.self) { (response) in
            completionHandler(response.value, self, response.response?.statusCode ?? -1)
        }
    }
}

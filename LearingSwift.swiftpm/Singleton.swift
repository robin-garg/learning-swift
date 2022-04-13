//
//  File.swift
//  LearingSwift
//
//  Created by Apple on 12/04/22.
//

import Foundation
import UIKit

struct LoggedInUser { }

/* Singleton */
// If we want to only extend functionalty of our API client class. Then we can make it final and extend behaviour using extenstions. But if we want to also override behavior then we can't make our call final.
final class ApiClient {
//    In Swift static let is constant and lazy loaded so we don't need to define private     varible and static function to access Singleton variable.
//    private static let instance = ApiClient()
//    static func getInstance() -> ApiClient {
//        return instance
//    }
    static let instance = ApiClient()

    private init() {}
    
    func login(completion: (LoggedInUser) -> Void) {}
}

//let client = ApiClient.getInstance()
let client = ApiClient.instance

/* singleton */
// Here we have shared instance of URLSession class but we can also create new instance of URLSession so its not Singleton. As we can create more then one instance of Class.  This patteren is called singleton with small 's'. Which provide us convenience with shared unmutable object.
// URLSession.shared
// URLSession()

/* Global mutable state */
// Here we have settable object. So we can't say it neither Singleton/singleton. But a mutable Global state. Where we can change the instance of class with some MockAPIClient to test the API Client
class GlobalApiClient {
    static var instance = GlobalApiClient()

    private init() {}
}

class MockAPIClient: GlobalApiClient {
    init() { }
    
}

GlobalApiClient.instance = MockAPIClient()

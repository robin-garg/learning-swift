//
//  File.swift
//  LearingSwift
//
//  Created by Apple on 14/04/22.
//

import Foundation
import UIKit

/*
 This example is to show how we can create Networking layer effectively where we can also scale our app easily and also reuse. In case if we are using a package as networking and it changes in future. Even then it will not break our app flow. As we can handle it on root level. It was just the basic of concepts not in depth but we will learn it in depth as we move forward in the course.
 */

// Main Module
extension ApiClient {
    func login(completion: (LoggedInUser) -> Void) {}
}

extension ApiClient {
    func loadFeed(completion: ([FeedItem]) -> Void) {}
}

extension ApiClient {
    func loadFollowers(completion: ([UserItem]) -> Void) {}
}

// API Module
class ApiClient {
    static let instance = ApiClient()

    private init() {}
    
    // Level 1
    // If we notice one thing here login controller only cares about login function not loadFeed and loadFollowers and same for the Feed and Followers controller. Here if we add new controller then we have to add new method to ApiClient and list will go long and long. Adding new methods might break existing functions. So this is not a good practice. This also make it difficult to reuse code. Because we can't reuse any of the login, feed or followers module. As next level of abstraction what we can do is we can create extenstions for different modules.
//    func login(completion: (LoggedInUser) -> Void) {}
//    func loadFeed(completion: ([FeedItem]) -> Void) {}
//    func loadFollowers(completion: ([UserItem]) -> Void) {}
    
    // Level 2
    // Now Login, Feed and Followers extenstions will call this execute method. Even with this method we have problems. Becuse our view controllers --are tightly coupled with--> ApiClient. So to make this architecture more flexible we have to revert the dependency (View Controller <---- ApiClient). Where api client is dependent on View controllers. To do that we will use protocols/closure in View controller to depend on ApiClient instead of property injection. Check view controllers.
    func execute(_ : URLRequest, completion: (Data) -> Void) {}
}

// Not Testable
//class LoginViewController: UIViewController {
//
//    func didTapLoginButton() {
//        ApiClient.instance.login() { user in
//            // handle response
//        }
//    }
// }

// Testable by subclassing
// Here we can subclass our ApiClient with MockApiClient and inject as property into the view controller and test our app
class MockApiClient: ApiClient { }

// Login Module
struct LoggedInUser { }

// As level 4 we can move this to main module and inject functions into view controllers at time of initalisation.
//extension ApiClient {
//    func login(completion: (LoggedInUser) -> Void) {}
//}

class LoginViewController: UIViewController {
    // Level 1, 2
//    var api = ApiClient.instance
    // Level 4 (Level 3 same implementation without extensions)
    // If we want to load data into ViewModal in case of MVVM. We can easily replace our controller with ViewModal.
    var login: (((LoggedInUser) -> Void) -> Void)?
    
    func didTapLoginButton() {
        login? { user in
            // navigate to feed view controller
        }
    }
 }

// Feed Module
struct FeedItem { }

//extension ApiClient {
//    func loadFeed(completion: ([FeedItem]) -> Void) {}
//}
class FeedViewController: UIViewController {
//    var api = ApiClient.instance
    var loadFeed: ((([FeedItem]) -> Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFeed? { feeds in
            
        }
    }
    func didTapLoginButton() {
        ApiClient.instance.login() { user in
            // handle response
        }
    }
 }

// Followers Module
struct UserItem { }

//extension ApiClient {
//    func loadFollowers(completion: ([UserItem]) -> Void) {}
//}

class FollowersViewController: UIViewController {
//    var api = ApiClient.instance
    var loadFollowers: ((([UserItem]) -> Void) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFollowers? { followers in
            
        }
    }
 }

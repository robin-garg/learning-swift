import UIKit

// We can also implement this with protocol instead of closure without making much changes to the view controller
protocol FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void)
}
//typealias FeedLoader  = (([String]) -> Void) -> Void

class FeedViewControllerOld: UIViewController {
    var loader: FeedLoader!
    
    convenience init (loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.loadFeed { feeds in
            // update ui
        }
    }
}

// So here we can fetch feeds in multiple ways i.e from Webservice or local so to implement different solutions without making our solution complex or messy. We can create new classes which confirms to protocol eg.

class RemoteFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // Get feeds from web service
    }
}

class LocalFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // Get feeds from local db.
    }
}

// So suppose if we have requirement that we need to get data from Remote but if internet is not available then get data locally. Then how we can implement that. So lets rewrite our view conroller to implement this. But first we need to create Reachability logic

struct Reachability {
    static let networkAvailable = false
}

class FeedViewControllerL2: UIViewController {
    var remote: RemoteFeedLoader!
    var local: LocalFeedLoader!
    
    convenience init (remote: RemoteFeedLoader, local: LocalFeedLoader) {
        self.init()
        self.remote = remote
        self.local = local
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.networkAvailable {
            remote.loadFeed { feeds in
                // update ui
            }
        } else {
            local.loadFeed { feeds in
                // update ui
            }
        }
    }
}

// So this will make our view controller messy. To clean our view controller what we can do is ceate a new type to get remove and local based on network availability and move above code into that type

class RemoteWithLocalFallbackFeedLoader: FeedLoader {
    var remote: RemoteFeedLoader
    var local: LocalFeedLoader
    
    init (remote: RemoteFeedLoader, local: LocalFeedLoader) {
        self.remote = remote
        self.local = local
    }

    func loadFeed(completion: @escaping ([String]) -> Void) {
//        if Reachability.networkAvailable {
//            remote.loadFeed { feeds in
//                // update ui
//            }
//        } else {
//            local.loadFeed { feeds in
//                // update ui
//            }
//        }
        // or we can refactor our code to
        let loadFeed = Reachability.networkAvailable ? remote.loadFeed : local.loadFeed;
        loadFeed(completion)
    }
}

// So now we can rewrite our view controller and use FeedLoader again as loader protocol. Now all the complexity has been hidden behing protocol.

class FeedViewController: UIViewController {
    var loader: FeedLoader!
    
    convenience init (loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        loader.loadFeed { feeds in
            // update ui
        }
    }
}

// So with this implementation we give view controllers many powers to load only from remote or only from local or get remote and fallback as local. and we can add other combinations as well. without changing the View controller see below how to implement that.

let vc = FeedViewController(loader: RemoteFeedLoader())
let vc2 = FeedViewController(loader: LocalFeedLoader())
let vc3 = FeedViewController(loader: RemoteWithLocalFallbackFeedLoader(remote: RemoteFeedLoader(), local: LocalFeedLoader()))
// Or if we are using storyboards even then we can pass loader into view controller
let vcStroyboard = FeedViewController()
vcStroyboard.loader =
RemoteWithLocalFallbackFeedLoader(remote: RemoteFeedLoader(), local: LocalFeedLoader())




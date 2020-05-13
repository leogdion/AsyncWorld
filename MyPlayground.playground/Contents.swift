// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "no such module ..."
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Foundation
import NIO
import _NIO1APIShims
import NIOTLS
import NIOHTTP1
import NIOConcurrencyHelpers
import NIOFoundationCompat
import NIOWebSocket
import NIOTestUtils
import PromiseKit
import Promises


struct Post : Codable {
  let userId : Int
  let id: Int
  let title: String
  let body: String
}

let threadPool = MultiThreadedEventLoopGroup(numberOfThreads: 4)
let eventLoop = threadPool.next()
let baseURL = URL(string: "https://jsonplaceholder.typicode.com/posts/")!
let decoder = JSONDecoder()

@discardableResult
func callbackDownloadPost(withId postId: Int, _ completion: @escaping ((Result<Post,Error>) -> Void)) -> URLSessionDataTask {
  
  let task = URLSession.shared.dataTask(with: baseURL.appendingPathComponent("\(postId)")) { (data, _, error) in
    if let error = error {
      completion(.failure(error))
      return
    }
    guard let data = data else {
      preconditionFailure()
    }
    let post : Post
    do {
      post = try decoder.decode(Post.self, from: data)
    } catch {
      completion(.failure(error))
      return
    }
    completion(.success(post))
  }
  
  task.resume()
  return task
}

func nioDownloadPost (withId postId: Int) -> EventLoopFuture<Post> {
  let nioPromise = eventLoop.makePromise(of: Post.self)
  callbackDownloadPost(withId: postId, nioPromise.completeWith)
  return nioPromise.futureResult
}


import Foundation
import NIO
import PlaygroundSupport

extension Schema {
  public static func nioDownload(withId id: Int, using decoder: JSONDecoder, on eventLoop: EventLoop) -> EventLoopFuture<Self> {
    let nioPromise = eventLoop.makePromise(of: Self.self)
    Self.download(withId: id, using: decoder, nioPromise.completeWith)
    return nioPromise.futureResult
  }
}

let threadPool = MultiThreadedEventLoopGroup(numberOfThreads: 4)
let eventLoop = threadPool.next()
let jsonDecoder = JSONDecoder()

let nioFutures = (1 ... 100).map {
  Post.nioDownload(withId: $0, using: jsonDecoder, on: eventLoop).flatMap { (post) -> EventLoopFuture<AuthoredPost> in
    User.nioDownload(withId: post.userId, using: jsonDecoder, on: eventLoop).map { (user) -> (AuthoredPost) in
      AuthoredPost(author: user, post: post)
    }
  }
}

let nioFlattened = EventLoopFuture.whenAllSucceed(nioFutures, on: eventLoop)

PlaygroundPage.current.needsIndefiniteExecution = true

nioFlattened.whenComplete { result in
  switch result {
  case let .failure(error):
    print(error)
  case let .success(posts):
    for aPost in posts {
      print(aPost.post.title, "by", aPost.author.name)
    }
  }
  PlaygroundPage.current.finishExecution()
}

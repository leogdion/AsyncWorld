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
  Post.nioDownload(withId: $0, using: jsonDecoder, on: eventLoop).map {
    $0.title
  }
}

let nioFlattened = EventLoopFuture.whenAllSucceed(nioFutures, on: eventLoop)

PlaygroundPage.current.needsIndefiniteExecution = true

nioFlattened.whenComplete { _ in
  switch titles {
  case let .failure(error):
    print(error)
  case let .success(titles):
    print(titles)
  }
  PlaygroundPage.current.finishExecution()
}

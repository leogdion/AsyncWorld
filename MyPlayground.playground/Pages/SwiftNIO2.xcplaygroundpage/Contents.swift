// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "no such module ..."
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Foundation
import NIO

import PromiseKit
import PlaygroundSupport

import Promises

typealias Promise = PromiseKit.Promise
typealias GooglePromise = Promises.Promise

let threadPool = MultiThreadedEventLoopGroup(numberOfThreads: 4)
let eventLoop = threadPool.next()

extension Schema {
  public static func nioDownload(withId id: Int, using decoder: JSONDecoder, on eventLoop: EventLoop) -> EventLoopFuture<Self> {
    let nioPromise = eventLoop.makePromise(of: Self.self)
    Self.download(withId: id, using: decoder, nioPromise.completeWith)
    return nioPromise.futureResult
  }
}

let jsonDecoder = JSONDecoder()

let nioFutures = (1...100).map{
  Post.nioDownload(withId: $0, using: jsonDecoder, on: eventLoop)
}

let nioFlattened = EventLoopFuture.whenAllSucceed(nioFutures, on: eventLoop)


PlaygroundPage.current.needsIndefiniteExecution = true

nioFlattened.whenComplete { (result) in
  let titles = result.map {
    $0.map{ $0.title }
  }
  switch titles {
  case .failure(let error):
    print(error)
  case .success(let titles):
    print(titles)
  }
  PlaygroundPage.current.finishExecution()
}

import Foundation
import PlaygroundSupport
import PromiseKit

let jsonDecoder = JSONDecoder()

extension Schema {
  static func promiseDownload(withId id: Int, using decoder: JSONDecoder) -> Promise<Self> {
    return Promise { resolver in
      Self.download(withId: id, using: decoder, resolver.resolve)
    }
  }
}

let pkFutures = (1 ... 100).map {
  Post.promiseDownload(withId: $0, using: jsonDecoder).then { post in
    User.promiseDownload(withId: post.userId, using: jsonDecoder).map { user in
      AuthoredPost(author: user, post: post)
    }
  }
}

let pkFlattened = when(fulfilled: pkFutures)

PlaygroundPage.current.needsIndefiniteExecution = true

pkFlattened.done { posts in
  for aPost in posts {
    print(aPost.post.title, "by", aPost.author.name)
  }
}.catch { error in
  print("ERROR:", error)
}.finally {
  PlaygroundPage.current.finishExecution()
}

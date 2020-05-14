import Foundation
import PlaygroundSupport
import Promises

let jsonDecoder = JSONDecoder()

extension Schema {
  static func gpDownload(withId id: Int, using decoder: JSONDecoder) -> Promise<Self> {
    return Promise { fulfill, reject in
      Self.download(withId: id, using: decoder) { result in
        switch result {
        case let .success(value):
          fulfill(value)
        case let .failure(error):
          reject(error)
        }
      }
    }
  }
}

let gpFutures = (1 ... 100).map { postId in
  Post.gpDownload(withId: postId, using: jsonDecoder).then { post in
    User.gpDownload(withId: post.userId, using: jsonDecoder).then { user in
      AuthoredPost(author: user, post: post)
    }
  }
}

let gpFlattened = all(gpFutures)

PlaygroundPage.current.needsIndefiniteExecution = true

gpFlattened.then { posts in
  for aPost in posts {
    print(aPost.post.id, aPost.post.title, "by", aPost.author.name)
  }
}.catch { error in
  print("ERROR:", error)
}.always {
  PlaygroundPage.current.finishExecution()
}

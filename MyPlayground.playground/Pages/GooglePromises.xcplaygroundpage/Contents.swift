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

let gpFutures = (1 ... 100).map {
  Post.gpDownload(withId: $0, using: jsonDecoder).then {
    $0.title
  }
}

let gpFlattened = all(gpFutures)

PlaygroundPage.current.needsIndefiniteExecution = true

gpFlattened.then { titles in
  print(titles)
}.catch { error in
  print("ERROR:", error)
}.always {
  PlaygroundPage.current.finishExecution()
}

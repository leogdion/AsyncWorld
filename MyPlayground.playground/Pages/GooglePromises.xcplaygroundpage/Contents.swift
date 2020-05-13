// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "no such module ..."
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Foundation

import Promises
import PlaygroundSupport

let jsonDecoder = JSONDecoder()

extension Schema {
  static func gpDownload(withId id: Int, using decoder: JSONDecoder) -> Promise<Self> {
    return Promise{ fulfill, reject in
      Self.download(withId: id, using: decoder) { (result) in
            switch result {
            case .success(let value):
              fulfill(value)
            case .failure(let error):
              reject(error)
            }
          }
    }
  }
}



//
//func googlePromiseDownload<Element:Schema>(_ type: Element.Type, withId id: Int) -> GooglePromise<Element> {
//  return GooglePromise<Element>(on: .main){ fulfill, reject in
//    callbackDownload(Element.self, withId: id) { (result) in
//      switch result {
//      case .success(let value):
//        fulfill(value)
//      case .failure(let error):
//        reject(error)
//      }
//    }
//  }
//}


let gpFutures = (1...100).map{
  Post.gpDownload(withId: $0, using: jsonDecoder).then{
    $0.title
  }
}

let gpFlattened = all(gpFutures)


PlaygroundPage.current.needsIndefiniteExecution = true

gpFlattened.then{
  (titles) in
  print(titles)
}.catch{
  (error) in
  print("ERROR:", error)
}.always {
     PlaygroundPage.current.finishExecution()
}

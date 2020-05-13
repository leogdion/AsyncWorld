// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "no such module ..."
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Foundation

import PromiseKit
import PlaygroundSupport

let jsonDecoder = JSONDecoder()

extension Schema {
  static func promiseDownload(withId id: Int, using decoder: JSONDecoder) -> Promise<Self> {
    return Promise { (resolver) in
      Self.download(withId: id, using: decoder, resolver.resolve)
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


let pkFutures = (1...100).map{
  Post.promiseDownload(withId: $0, using: jsonDecoder).map{
    $0.title
  }
}

let pkFlattened = when(fulfilled: pkFutures)


PlaygroundPage.current.needsIndefiniteExecution = true

pkFlattened.done{
  (titles) in
  print(titles)
}.catch{
  (error) in
  print("ERROR:", error)
}.finally {
     PlaygroundPage.current.finishExecution()
}

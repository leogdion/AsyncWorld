import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

protocol ResultType {
  associatedtype Success
  associatedtype Failure

  var success: Success? { get }
  var failure: Failure? { get }
}

extension Result: ResultType {
  var success: Success? {
    return try? get()
  }

  var failure: Failure? {
    guard case let .failure(failure) = self else {
      return nil
    }
    return failure
  }
}

extension Optional where Wrapped: ResultType {
  var success: Wrapped.Success? {
    flatMap { $0.success }
  }

  var failure: Wrapped.Failure? {
    flatMap { $0.failure }
  }

  var none: Void? {
    return self != nil ? nil : ()
  }
}

extension Schema {
  static func publisher(withId id: Int, using decoder: JSONDecoder) -> AnyPublisher<Self, Error> {
    return Future { fulfill in
      Self.download(withId: id, using: decoder, fulfill)
    }.eraseToAnyPublisher()
  }
}

struct ContentView: View {
  @EnvironmentObject var dataObject: DataObject

  var body: some View {
    ZStack {
      Group {
        errorView
      }
      Group {
        self.dataObject.authoredPosts.success.map { posts in
          VStack {
            ForEach(posts, id: \.post.id) { post in
              Text(post.post.title)
            }
          }
        }
      }
      busyView
    }.onAppear {
      self.dataObject.begin()
    }.frame(width: 300, height: 1000, alignment: .top)
  }

  var errorView: some View {
    self.dataObject.authoredPosts.failure.map {
      Text($0.localizedDescription)
    }
  }

  var successView: some View {
    self.dataObject.authoredPosts.success.map { posts in
      VStack {
        ForEach(posts, id: \.post.id) { post in Text(post.post.title)
        }
      }
    }
  }

  var busyView: some View {
    self.dataObject.authoredPosts.none.map {
      Text("Busy")
    }
  }
}

class DataObject: ObservableObject {
  var cancellable: AnyCancellable!
  let jsonDecoder = JSONDecoder()
  var loadActive = CurrentValueSubject<Bool, Never>(false)
  @Published var authoredPosts: Result<[AuthoredPost], Error>?

  init() {
    let publisher = loadActive.filter { $0 }.flatMap { _ -> AnyPublisher<Result<[AuthoredPost], Error>, Never> in
      let publishers = (1 ... 100).map {
        Post.publisher(withId: $0, using: self.jsonDecoder).flatMap { post in
          User.publisher(withId: post.userId, using: self.jsonDecoder).map { user in
            AuthoredPost(author: user, post: post)
          }
        }.eraseToAnyPublisher()
      }

      return Publishers.MergeMany(publishers).collect().map { posts in
        Result<[AuthoredPost], Error>.success(posts)
      }.catch { error in
        Just<Result<[AuthoredPost], Error>>(.failure(error))
      }.eraseToAnyPublisher()
    }

    cancellable = publisher.receive(on: DispatchQueue.main).sink {
      self.authoredPosts = $0
    }
  }

  func begin() {
    loadActive.send(true)
  }
}

PlaygroundPage.current.setLiveView(ContentView().environmentObject(DataObject()))

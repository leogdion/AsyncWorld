import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

extension Schema {
  static func publisher(withId id: Int, using decoder: JSONDecoder) -> AnyPublisher<Self, Error> {
    return Future { fulfill in
      Self.download(withId: id, using: decoder, fulfill)
    }.eraseToAnyPublisher()
  }
}

struct AuthoredPostsView: View {
  @EnvironmentObject var dataObject: DataObject

  var body: some View {
    Text("Hello World")
  }
}

class DataObject: ObservableObject {
  var cancellable: AnyCancellable!
  let jsonDecoder = JSONDecoder()
  var authoredPosts: Result<[AuthoredPost], Error>?

  init() {
    let publishers = (1 ... 100).map {
      Post.publisher(withId: $0, using: self.jsonDecoder).flatMap { post in
        User.publisher(withId: post.userId, using: self.jsonDecoder).map { user in
          AuthoredPost(author: user, post: post)
        }
      }.eraseToAnyPublisher()
    }

    let publisher = Publishers.MergeMany(publishers).collect().map { posts in
      Result<[AuthoredPost], Error>?.some(.success(posts))
    }.catch { error in
      Just<Result<[AuthoredPost], Error>?>(.failure(error))
    }

    cancellable = publisher.receive(on: DispatchQueue.main).sink {
      self.authoredPosts = $0
    }
  }
}

PlaygroundPage.current.setLiveView(AuthoredPostsView().environmentObject(DataObject()))

import Foundation


public protocol Schema : Codable {
  static var name : String { get }
}

public struct Post : Schema {
  public static let name = "posts"
  public let userId : Int
  public let id: Int
  public let title: String
  public let body: String
}

public struct User : Schema {
  public static let name = "users"
  public let id: Int
  public let name: String
  public let username : String
  public let email : String
}

let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!

public extension Schema {
  @discardableResult
  public static func download(withId id: Int, using decoder: JSONDecoder,  _ completion: @escaping ((Result<Self,Error>) -> Void)) -> URLSessionDataTask {
    let task = URLSession.shared.dataTask(with: baseURL.appendingPathComponent(Self.name).appendingPathComponent("\(id)")) { (data, _, error) in
      if let error = error {
        completion(.failure(error))
        return
      }
      guard let data = data else {
        preconditionFailure()
      }
      let element : Self
      do {
        element = try decoder.decode(Self.self, from: data)
      } catch {
        completion(.failure(error))
        return
      }
      completion(.success(element))
    }
    
    task.resume()
    return task
  }
}

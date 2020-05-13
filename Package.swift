// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AsyncWorld",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "AsyncWorld",
      targets: ["AsyncWorld"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "AsyncWorld",
      dependencies: []
    ),
    .testTarget(
      name: "AsyncWorldTests",
      dependencies: ["AsyncWorld"]
    )
  ]
)

package.dependencies = [
  .package(name: "swift-nio", url: "https://github.com/apple/swift-nio.git", from: "2.17.0"),
  .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit.git", .revision("cd1a9b83ab2c65965d97af964b9f661fb9f84375")),
  .package(name: "Promises", url: "https://github.com/google/promises.git", from: "1.2.8")
]
package.targets = [
  .target(name: "AsyncWorld",
          dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "_NIO1APIShims", package: "swift-nio"),
            .product(name: "NIOTLS", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
            .product(name: "NIOWebSocket", package: "swift-nio"),
            .product(name: "NIOTestUtils", package: "swift-nio"),
            .product(name: "PromiseKit", package: "PromiseKit"),
            .product(name: "FBLPromises", package: "Promises"),
            .product(name: "FBLPromisesTestHelpers", package: "Promises"),
            .product(name: "Promises", package: "Promises"),
            .product(name: "PromisesTestHelpers", package: "Promises")
          ])
]

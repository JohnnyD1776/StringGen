// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TypeLocXC",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .executable(name: "TypeLocXC", targets: ["TypeLocXC"])
  ],
  dependencies: [
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
  ],
  targets: [
    .executableTarget(
      name: "TypeLocXC",
      dependencies: ["Yams"]
    )
  ]
)

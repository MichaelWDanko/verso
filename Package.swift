// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "Verso", platforms: [.macOS(.v14)], products: [
    .executable(name: "Verso", targets: ["Verso"])
], targets: [
    .target(name: "VersoCore"),
    .executableTarget(name: "Verso", dependencies: ["VersoCore"]),
    .testTarget(name: "VersoCoreTests", dependencies: ["VersoCore"])
])

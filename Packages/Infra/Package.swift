// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Infra",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Infra", targets: ["Infra"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "Infra", dependencies: ["Domain"]),
    ]
)

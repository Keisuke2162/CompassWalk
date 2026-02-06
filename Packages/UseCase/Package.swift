// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UseCase",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "UseCase", targets: ["UseCase"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "UseCase", dependencies: ["Domain"]),
    ]
)

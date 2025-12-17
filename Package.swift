// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Smozie",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Smozie",
            targets: ["Smozie"]
        ),
    ],
    targets: [
        .target(
            name: "Smozie",
            path: "Sources/Smozie"
        ),
    ]
)


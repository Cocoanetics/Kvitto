// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kvitto",
    platforms: [
        .iOS(.v9),         //.v8 - .v13
        .macOS(.v10_10),    //.v10_10 - .v10_15
        .tvOS(.v9),        //.v9 - .v13
    ],
    products: [
        .library(
            name: "Kvitto",
            targets: ["Kvitto"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Cocoanetics/DTFoundation.git", from: "1.7.15"),
    ],
    targets: [
        .target(
            name: "Kvitto",
            dependencies: [
                .product(name: "DTFoundation", package: "DTFoundation"),
            ],
			path: "Core"),
        .testTarget(
            name: "KvittoTests",
            dependencies: ["Kvitto"],
			path: "Test"),
    ]
)

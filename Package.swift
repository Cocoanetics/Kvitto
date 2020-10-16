// swift-tools-version:5.3

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
        .package(url: "https://github.com/Cocoanetics/DTFoundation.git", 
		.branch("develop"))
//		from: "1.7.15"),
    ],
    targets: [
        .target(
            name: "Kvitto",
            dependencies: [
                .product(name: "DTFoundation", 
				package: "DTFoundation"),
            ],
            path: "Core",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "KvittoTests",
            dependencies: ["Kvitto"],
            path: "Test",
            exclude: ["Info.plist"],
            resources: [.copy("Resources")]),
    ]
)

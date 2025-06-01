// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RichPromizeSDK",
    platforms: [
        .iOS(.v13) // Specify the supported platform versions
    ],
    products: [
        .library(
            name: "RichPromizeSDK",
            targets: ["RichPromizeSDK"]
        )
    ],
    dependencies: [
        // List external dependencies here if needed
    ],
    targets: [
        .binaryTarget(
            name: "RichPromizeSDK",
            path: "RichPromizeSDK.xcframework" // Ensure the path to the `.xcframework` is correct
        )
    ]
)

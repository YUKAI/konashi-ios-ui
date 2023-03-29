// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "konashi-ios-ui",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "KonashiUI",
            targets: ["KonashiUI"]
        )
    ],
    dependencies: [
        .package(
            name: "Konashi",
            url: "https://github.com/YUKAI/konashi-ios-sdk2.git", 
            from: "1.0.0"
        ),
        .package(
            name: "Promises", 
            url: "https://github.com/google/promises.git", 
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/JonasGessner/JGProgressHUD.git", 
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "KonashiUI",
            dependencies: [
                "Konashi",
                "Promises",
                "JGProgressHUD"
            ]
        ),
        .testTarget(
            name: "KonashiUITests",
            dependencies: ["KonashiUI"]
        )
    ]
)

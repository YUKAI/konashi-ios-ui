// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KonashiUI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KonashiUI",
            targets: ["KonashiUI"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Konashi", url: "https://github.com/YUKAI/konashi-ios-sdk2.git", from: "0.2.0"),
        .package(name: "Promises", url: "https://github.com/google/promises.git", from: "2.0.0"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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

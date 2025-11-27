// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "VizbeeTPlayKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "VizbeeTPlayKit",
            targets: ["VizbeeTPlayKit"])
    ],
    targets: [
        .binaryTarget(
            name: "VizbeeTPlayKit",
            path: "VizbeeTPlayKit.xcframework")
    ])

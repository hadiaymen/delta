// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DELTA",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DELTA",
            targets: ["DELTA"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DELTA",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DELTATests",
            dependencies: ["DELTA"],
            path: "Tests/DELTATests"
        )
    ]
)

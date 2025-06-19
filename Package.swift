// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerformanceHUD",
	platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "performance-hud",
            targets: ["performance-hud"]),
    ],
    targets: [
        .target(
            name: "performance-hud"),
    ]
)

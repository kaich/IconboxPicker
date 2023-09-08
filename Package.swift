// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IconboxPicker",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "IconboxPicker",
            targets: ["IconboxPicker"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "IconboxPicker",
            path: "IconboxPicker/Classes"),
    ]
)

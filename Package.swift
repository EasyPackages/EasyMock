// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyMock",
    products: [
        .library(name: "EasyMock", targets: ["EasyMock"]),
    ],
    targets: [
        .target(name: "EasyMock"),
        .testTarget(
            name: "EasyMockTests",
            dependencies: ["EasyMock"]
        ),
    ]
)

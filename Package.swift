// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FSM",
    products: [
        .library(
            name: "FSM",
            type: .dynamic,
            targets: [
                "swiftfsm"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(name: "FSM", dependencies: []),
        .target(name: "swiftfsm", dependencies: ["FSM"]),
        .testTarget(name: "FSMTests", dependencies: [
            .target(name: "FSM"),
            .target(name: "swiftfsm"),
        ])
    ]
)

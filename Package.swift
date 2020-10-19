// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FSM",
    products: [
        .library(
            name: "FSM",
            targets: [
                "swiftfsm"
            ]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/swift_helpers.git", .branch("master"))
    ],
    targets: [
        .target(name: "Utilities", dependencies: []),
        .target(name: "FSM", dependencies: ["Functional", "Utilities"]),
        .target(name: "ExternalVariables", dependencies: ["Functional", "Utilities", "FSM"]),
        .target(name: "swiftfsm", dependencies: [
            "Functional",
            "Utilities",
            "FSM",
            "ExternalVariables",
            "Hashing",
            "IO",
            "Trees",
            "swift_helpers"
        ]),
        .testTarget(name: "FSMTests", dependencies: [
            .target(name: "FSM"),
            .target(name: "swiftfsm"),
            .target(name: "ExternalVariables")
        ])
    ]
)

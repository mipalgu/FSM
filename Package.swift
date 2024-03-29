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
        .package(url: "https://github.com/mipalgu/KripkeStructures", from: "1.0.0")
    ],
    targets: [
        .target(name: "Utilities", dependencies: []),
        .target(name: "FSM", dependencies: ["Utilities", .product(name: "KripkeStructures", package: "KripkeStructures")]),
        .target(name: "ExternalVariables", dependencies: ["Utilities", "FSM"]),
        .target(name: "swiftfsm", dependencies: [
            "Utilities",
            "FSM",
            "ExternalVariables"
        ]),
        .testTarget(name: "FSMTests", dependencies: [
            .target(name: "FSM"),
            .target(name: "swiftfsm"),
            .target(name: "ExternalVariables")
        ])
    ]
)

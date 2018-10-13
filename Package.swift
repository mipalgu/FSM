// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "libs",
    products: [
        .library(
            name: "FSM",
            type: .dynamic,
            targets: ["Utilities", "KripkeStructure", "ModelChecking", "FSM", "ExternalVariables", "FSMVerification", "swiftfsm"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/swift_wb.git", .branch("swift-4.2")),
        .package(url: "ssh://git.mipal.net/git/swift_helpers.git", .branch("master"))
    ],
    targets: [
        .target(name: "Utilities", dependencies: []),
        .target(name: "KripkeStructure", dependencies: ["Functional", "Utilities"]),
        .target(name: "ModelChecking", dependencies: ["Functional", "Hashing", "Utilities", "KripkeStructure"]),
        .target(name: "FSM", dependencies: ["Functional", "Utilities", "KripkeStructure", "ModelChecking"]),
        .target(name: "ExternalVariables", dependencies: ["GUSimpleWhiteboard", "Functional", "Utilities", "KripkeStructure", "ModelChecking", "FSM"]),
        .target(name: "FSMVerification", dependencies: ["Functional", "Utilities", "KripkeStructure", "ModelChecking", "FSM"]),
        .target(name: "swiftfsm", dependencies: ["Functional", "Utilities", "KripkeStructure", "FSM", "ModelChecking"]),
        .testTarget(name: "FSMTests", dependencies: [
            .target(name: "FSM"),
            .target(name: "swiftfsm"),
            .target(name: "ModelChecking"),
            .target(name: "FSMVerification"),
            .target(name: "ExternalVariables"),
            .target(name: "KripkeStructure")
        ])
    ]
)

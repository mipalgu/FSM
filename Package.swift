// swift-tools-version:4.0

//swiftlint:disable line_length

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
        .package(url: "ssh://git.mipal.net/git/swift_wb.git", .branch("swift-4.2")),
        .package(url: "ssh://git.mipal.net/git/swift_helpers.git", .branch("master"))
    ],
    targets: [
        .target(name: "Utilities", dependencies: []),
        .target(name: "Logic", dependencies: []),
        .target(name: "KripkeStructure", dependencies: ["Functional", "Utilities", "Logic"]),
        .target(name: "KripkeStructureViews", dependencies: ["Hashing", "IO", "KripkeStructure", "swift_helpers"]),
        .target(name: "ModelChecking", dependencies: ["Functional", "Hashing", "IO", "swift_helpers", "Utilities", "KripkeStructure", "KripkeStructureViews"]),
        .target(name: "FSM", dependencies: ["Functional", "Utilities", "KripkeStructure", "ModelChecking"]),
        .target(name: "ExternalVariables", dependencies: ["Functional", "Utilities", "KripkeStructure", "ModelChecking", "FSM"]),
        .target(name: "FSMVerification", dependencies: ["Functional", "Utilities", "KripkeStructure", "ModelChecking", "FSM"]),
        .target(name: "swiftfsm", dependencies: [
            "Functional",
            "Utilities",
            "KripkeStructure",
            "KripkeStructureViews",
            "ModelChecking",
            "FSM",
            "ExternalVariables",
            "FSMVerification",
            "Hashing",
            "IO",
            "Trees",
            "swift_helpers"
        ]),
        .testTarget(name: "LogicTests", dependencies: [.target(name: "Logic")]),
        .testTarget(name: "ModelCheckingTests", dependencies: [
            .target(name: "ModelChecking")
        ]),
        .testTarget(name: "FSMTests", dependencies: [
            .target(name: "FSM"),
            .target(name: "swiftfsm"),
            .target(name: "ModelChecking"),
            .target(name: "FSMVerification"),
            .target(name: "ExternalVariables"),
            .target(name: "KripkeStructure"),
            "GUSimpleWhiteboard"
        ])
    ]
)

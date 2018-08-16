// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "libs",
    products: [
        .library(
            name: "FSM",
            type: .dynamic,
            targets: ["Functional", "KripkeStructure", "FSM", "swiftfsm"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/swift_wb.git", .branch("master"))
    ],
    targets: [
        .target(name: "Functional", dependencies: []),
        .target(name: "KripkeStructure", dependencies: ["Functional"]),
        .target(name: "FSM", dependencies: ["GUSimpleWhiteboard", "Functional", "KripkeStructure"]),
        .target(name: "swiftfsm", dependencies: ["GUSimpleWhiteboard", "Functional", "KripkeStructure", "FSM"]),
        .testTarget(name: "FSMTests", dependencies: [.target(name: "FSM"), .target(name: "swiftfsm")])
    ]
)

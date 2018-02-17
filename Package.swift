// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "libs",
    products: [
        .library(
            name: "FSM",
            type: .dynamic,
            targets: ["Functional", "KripkeStructure", "FSM"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/swift_wb.git", .branch("master"))
    ],
    targets: [
        .target(name: "Functional", dependencies: []),
        .target(name: "KripkeStructure", dependencies: ["Functional"]),
        .target(name: "FSM", dependencies: ["GUSimpleWhiteboard", "Functional", "KripkeStructure"]),
        .testTarget(name: "FSMTests", dependencies: [.target(name: "FSM")])
    ]
)

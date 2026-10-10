// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BabyCore",
    defaultLocalization: "en",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "BabyCore", targets: ["BabyCore"]),
    ],
    targets: [
        .target(name: "Domain", resources: [.process("Localizable.xcstrings")]),
        .target(name: "BabyCore", dependencies: ["Domain"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(name: "BabyCoreTests", dependencies: ["BabyCore"]),
    ]
)

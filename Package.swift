// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "OpenClawBunny",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "OpenClawBunny", targets: ["OpenClawBunny"])
    ],
    targets: [
        .executableTarget(
            name: "OpenClawBunny",
            path: "Sources/OpenClawBunny"
        )
    ]
)

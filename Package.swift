// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DeepUninstaller",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "DeepUninstaller",
            targets: ["DeepUninstaller"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DeepUninstaller",
            dependencies: [],
            path: "Sources"
        )
    ]
)

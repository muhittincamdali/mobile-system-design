// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MobileSystemDesign",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MobileSystemDesign", targets: ["MobileSystemDesign"])
    ],
    targets: [
        .target(
            name: "MobileSystemDesign",
            path: "Sources/MobileSystemDesign"
        ),
        .testTarget(
            name: "MobileSystemDesignTests",
            dependencies: ["MobileSystemDesign"]
        )
    ]
)

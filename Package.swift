// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Crocodil",
    platforms: [
       .iOS(.v13),
       .macOS(.v14),
       .tvOS(.v12),
       .watchOS(.v7)

    ],
    products: [
        .library(
            name: "Crocodil",
            targets: ["Crocodil"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0"),
    ],
    targets: [
        .macro(
            name: "CrocodilMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Crocodil",
            dependencies: [
                "CrocodilMacros"
            ]
        ),
        .testTarget(
            name: "CrocodilTests",
            dependencies: ["Crocodil"]
        ),
        .testTarget(
            name: "CrocodilMacrosTests",
            dependencies: [
                "CrocodilMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
 

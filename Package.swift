// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Swift target
private let name: String = "SPFKLoudness"

// C/C++ target
private let nameC: String = "\(name)C"

private let platforms: [PackageDescription.SupportedPlatform]? = [
    .macOS(.v12)
]

private let products: [PackageDescription.Product] = [
    .library(
        name: name,
        targets: [name, nameC]
    )
]

private let dependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "SPFKUtils", path: "../SPFKUtils"),
    .package(name: "SPFKAudioBase", path: "../SPFKAudioBase"),
    .package(name: "SPFKTesting", path: "../SPFKTesting"),

]


private let targets: [PackageDescription.Target] = [
    // Swift
    .target(
        name: name,
        dependencies: [
            .target(name: nameC),
            .byNameItem(name: "SPFKUtils", condition: nil),
            .byNameItem(name: "SPFKAudioBase", condition: nil)
        ]
    ),
    
    // C
    .target(
        name: nameC,
        dependencies: [
        ],
        publicHeadersPath: "include",
        cSettings: [
            .headerSearchPath("include_private")
        ],
        cxxSettings: [
            .headerSearchPath("include_private")
        ]
    ),

    .testTarget(
        name: "\(name)Tests",
        dependencies: [
            .byNameItem(name: name, condition: nil),
            .byNameItem(name: nameC, condition: nil),
            .byNameItem(name: "SPFKTesting", condition: nil)
        ]
    )
]

let package = Package(
    name: name,
    defaultLocalization: "en",
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets,
    cxxLanguageStandard: .cxx20
)

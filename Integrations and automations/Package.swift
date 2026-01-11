// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Integrations and automations",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Integrations and automations",
            targets: ["Integrations and automations"]
        ),
        .executable(
            name: "IntegrationsStudio",
            targets: ["IntegrationsStudio"]
        ),
        .executable(
            name: "PetroWiseMac",
            targets: ["PetroWiseMac"]
        ),
        .library(
            name: "PetroWiseIOS",
            targets: ["PetroWiseIOS"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Integrations and automations"
        ),
        .executableTarget(
            name: "IntegrationsStudio",
            dependencies: ["Integrations and automations"]
        ),
        .executableTarget(
            name: "PetroWiseMac",
            dependencies: ["Integrations and automations"]
        ),
        .target(
            name: "PetroWiseIOS",
            dependencies: ["Integrations and automations"],
            path: "Sources/PetroWiseIOS",
            exclude: ["Widgets"]
        ),
        .testTarget(
            name: "Integrations and automationsTests",
            dependencies: ["Integrations and automations"]
        ),
    ]
)

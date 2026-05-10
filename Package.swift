// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReferralSDK",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "ReferralSDK", targets: ["ReferralSDK"]),
    ],
    targets: [
        .target(
            name: "ReferralSDK",
            dependencies: [],
            path: "Sources/ReferralSDK"
        ),
        .testTarget(
            name: "ReferralSDKTests",
            dependencies: ["ReferralSDK"],
            path: "Tests/ReferralSDKTests"
        ),
    ]
)

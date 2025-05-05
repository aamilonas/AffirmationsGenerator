// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AffirmationsGenerator",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "AffirmationsGenerator",
            dependencies: ["OpenAI"]
        )
    ]
) 
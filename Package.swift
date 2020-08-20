// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ReRxSwift",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "ReRxSwift",
            targets: ["ReRxSwift"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/ReSwift/ReSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/Quick/Quick.git",
            .upToNextMajor(from: "1.1.0")
        ),
        .package(
            url: "https://github.com/Quick/Nimble.git",
            .upToNextMajor(from: "7.0.0")
        ),
        .package(
            url: "https://github.com/RxSwiftCommunity/RxDataSources",
            .upToNextMajor(from: "4.0.0")
        )
    ],
    targets: [
        .target(
            name: "ReRxSwift",
            dependencies: [
                "RxSwift",
                "RxCocoa",
                "ReSwift"
            ],
            path: "ReRxSwift"
        ),
        .testTarget(
            name: "ReRxSwiftTests",
            dependencies: [
                "ReRxSwift",
                "Quick",
                "Nimble",
                "RxDataSources"
            ],
            path: "ReRxSwiftTests"
        )
    ]
)

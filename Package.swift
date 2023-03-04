// swift-tools-version:5.7

import PackageDescription

#if os(macOS)
    let dependencies: [Package.Dependency] = [
        .combineSchedulers,
        .ohHttpStubs,
        .swiftClocks,
    ]
    let targets: [Target] = [
        .target(name: "NetworkService"),
        .testTarget(
            name: "NetworkServiceTests",
            dependencies: [
                "NetworkService",
                .ohHttpStubs,
                .ohHttpStubsSwift,
            ]
        ),
        .target(
            name: "NetworkServiceTestHelper",
            dependencies: [
                "NetworkService",
                .combineSchedulers,
                .clocks,
            ]
        ),
        .testTarget(
            name: "NetworkServiceTestHelperTests",
            dependencies: [
                "NetworkServiceTestHelper",
                .clocks,
            ]
        ),
    ]
#else
    let dependencies: [Package.Dependency] = [
        .combineSchedulers,
        .swiftClocks,
    ]
    let targets: [Target] = [
        .target(name: "NetworkService"),
        .target(
            name: "NetworkServiceTestHelper",
            dependencies: [
                "NetworkService",
                .combineSchedulers,
                .clocks,
            ]
        ),
    ]
#endif

let package = Package(
    name: "NetworkService",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v7)],
    products: [
        .library(
            name: "NetworkService",
            targets: ["NetworkService"]
        ),
        .library(
            name: "NetworkServiceTestHelper",
            targets: ["NetworkServiceTestHelper"]
        ),
    ],
    dependencies: dependencies,
    targets: targets
)

extension Package.Dependency {
    static let ohHttpStubs: Package.Dependency = .package(
        url: "https://github.com/AliSoftware/OHHTTPStubs.git",
        from: "9.1.0"
    )
    static let combineSchedulers: Package.Dependency = .package(
        url: "https://github.com/pointfreeco/combine-schedulers.git",
        .upToNextMajor(from: "0.6.0")
    )

    static let swiftClocks: Package.Dependency = .package(
        url: "https://github.com/pointfreeco/swift-clocks.git",
        .upToNextMajor(from: "0.2.0")
    )
}

extension Target.Dependency {
    static let ohHttpStubs: Self = .product(name: "OHHTTPStubs", package: "OHHTTPStubs")
    static let ohHttpStubsSwift: Self = .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")

    static let combineSchedulers: Self = .product(name: "CombineSchedulers", package: "combine-schedulers")

    static let clocks: Self = .product(name: "Clocks", package: "swift-clocks")
}

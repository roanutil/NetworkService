// NetworkServiceTests.swift
// NetworkService
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

#if canImport(Combine)
    import Combine
    import Foundation
    import NetworkService
    import OHHTTPStubs
    import OHHTTPStubsSwift
    import XCTest

    final class NetworkServiceTests: NetworkTestCase {
        typealias Failure = NetworkService.Failure

        struct Lyric: TopLevelCodable, Equatable {
            static var encoder: JSONEncoder { JSONEncoder() }
            static var decoder: JSONDecoder { JSONDecoder() }

            let content: [String]

            static let test = Lyric(content: [
                "Never gonna give you up",
                "Never gonna let you down",
                "Never gonna run around and desert you",
                "Never gonna make you cry",
                "Never gonna say goodbye",
                "Never gonna tell a lie and hurt you",
            ])
        }

        func responseBodyEncoded() throws -> Data {
            try JSONEncoder().encode(Lyric.test)
        }

        let prefix = "http://"
        let host = "rick.astley.com"
        let path = "/never/gonna/give/you/up"

        func destinationURL() throws -> URL {
            try XCTUnwrap(URL(string: path, relativeTo: URL(string: prefix + host)))
        }

        static var allTests = [
            ("testDeleteSuccess", testDeleteSuccess),
            ("testDeleteFailure", testDeleteFailure),
            ("testGetSuccess", testGetSuccess),
            ("testGetFailure", testGetFailure),
            ("testPostSuccess", testPostSuccess),
            ("testPostFailure", testPostFailure),
            ("testPutSuccess", testPutSuccess),
            ("testPutFailure", testPutFailure),
        ]
    }
#endif

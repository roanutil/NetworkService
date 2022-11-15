// NetworkServiceTests+Post.swift
// NetworkService
//
// Copyright © 2022 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Combine
import Foundation
import NetworkServiceAsyncBeta
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

extension NetworkServiceTests {
    // MARK: Success

    func testPostSuccess() async throws {
        let url = try destinationURL()
        let data = (try? responseBodyEncoded()) ?? Data()
        stub(
            condition: isHost(host)
                && isPath(path)
                && isMethodPOST()
                && hasBody(data)
        ) { _ in
            HTTPStubsResponse(
                data: data,
                statusCode: Int32(HTTPURLResponse.StatusCode.ok),
                headers: [URLRequest.ContentType.key: URLRequest.ContentType.applicationJSON.value]
            )
        }

        let service = NetworkService()
        let result: Result<Lyric, Failure> = await service.post(data, to: url)
        XCTAssertEqual(try result.get(), Lyric.test)
    }

    // MARK: Failure

    func testPostFailure() async throws {
        let data = (try? responseBodyEncoded()) ?? Data()
        stub(
            condition: isHost(host)
                && isPath(path)
                && isMethodPOST()
                && hasBody(data)
        ) { _ in
            HTTPStubsResponse(
                data: data,
                statusCode: Int32(HTTPURLResponse.StatusCode.badRequest),
                headers: [URLRequest.ContentType.key: URLRequest.ContentType.applicationJSON.value]
            )
        }

        let service = NetworkService()
        let url = try destinationURL()
        let result: Result<Lyric, Failure> = await service.post(data, to: url)
        guard case let .failure(.httpResponse(response)) = result else {
            return XCTFail("Expecting failure but received success.")
        }
        XCTAssert(response.isClientError)
    }
}
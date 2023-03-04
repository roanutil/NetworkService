// NetworkServiceClient.swift
// NetworkService
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Dependency injection point for `NetworkService`
public protocol NetworkServiceClient {
    /// `NetworkService`'s error domain
    typealias Failure = NetworkService.Failure

    /// - Returns: Configured URLSession
    func getSession() -> URLSession

    /// Start a `URLRequest`
    /// - Parameter request: The request as a `URLRequest`
    /// - Returns: Type erased publisher with output as `Data` and `NetworkService`'s error domain for failure
    func start(_ request: URLRequest) async -> Result<Data, Failure>
}

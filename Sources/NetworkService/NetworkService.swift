// NetworkService.swift
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

/// Provides methods for making network requests and processing the resulting responses
public final class NetworkService {
    /// `NetworkService`'s error domain
    public enum Failure: Error, Hashable, Sendable {
        case urlResponse(URLResponse)
        case httpResponse(HTTPURLResponse)
        case urlError(URLError)
        case unknown(NSError)
    }

    public init() {}
}

// MARK: NetworkService+NetworkServiceClient

extension NetworkService: NetworkServiceClient {}

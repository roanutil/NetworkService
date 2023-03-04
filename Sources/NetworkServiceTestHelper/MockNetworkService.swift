// MockNetworkService.swift
// NetworkService
//
// Copyright © 2023 MFB Technologies, Inc. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Clocks
import Foundation
import NetworkService
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

#if canImport(Foundation.Clock)
    /// Convenience implementation of `NetworkServiceClient` for testing. Supports defining set output values for all
    /// network functions,
    /// repeating values, and delaying values.
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    open class MockNetworkService<T>: NetworkServiceClient where T: Clock, T.Duration == Duration {
        public var delay: Delay
        public var outputs: [MockOutput]
        var nextOutput: MockOutput?
        let clock: T

        public init(outputs: [MockOutput] = [], delay: Delay = .none, clock: T) {
            self.outputs = outputs
            self.delay = delay
            self.clock = clock
        }

        /// Manages the output queue and returns the new value for reach iteration.
        private func queue() throws -> MockOutput {
            guard outputs.count > 0 else {
                throw Errors.noOutputQueued
            }
            let next = outputs.removeFirst()
            if let repeated = next as? RepeatResponse {
                switch repeated {
                case let .repeat(value, count: count):
                    if count > 1 {
                        outputs.insert(RepeatResponse.repeat(value, count: count - 1), at: 0)
                    }
                case .repeatInfinite:
                    outputs.insert(repeated, at: 0)
                }
            }
            return next
        }

        /// Replaces default implementation from protocol. All `NetworkService` functions should eventually end up in
        /// this
        /// version of `start`.
        /// Delay and repeat are handled here.
        public func start(_: URLRequest) async -> Result<Data, Failure> {
            let next: MockOutput
            do {
                next = try queue()
            } catch {
                return .failure(Failure.unknown(error as NSError))
            }
            switch delay {
            case .infinite:
                return await Task {
                    try await clock.sleep(for: Duration.milliseconds(Int.max))
                    return try next.output.get()
                }
                .result.mapToNetworkError()
            case .seconds:
                return await Task {
                    try await clock.sleep(for: .seconds(delay.interval))
                    return try next.output.get()
                }
                .result.mapToNetworkError()
            case .none:
                return next.output
            }
        }

        public enum Errors: Error, Equatable {
            case noOutputQueued
        }
    }

#elseif canImport(Combine)
    import Combine
    import CombineSchedulers

    /// Convenience implementation of `NetworkServiceClient` for testing. Supports defining set output values for all
    /// network functions,
    /// repeating values, and delaying values.
    open class MockNetworkService<T: Scheduler>: NetworkServiceClient {
        public var delay: Delay
        public var outputs: [MockOutput]
        var nextOutput: MockOutput?
        let scheduler: T

        public init(outputs: [MockOutput] = [], delay: Delay = .none, scheduler: T) {
            self.outputs = outputs
            self.delay = delay
            self.scheduler = scheduler
        }

        /// Manages the output queue and returns the new value for reach iteration.
        private func queue() throws -> MockOutput {
            guard outputs.count > 0 else {
                throw Errors.noOutputQueued
            }
            let next = outputs.removeFirst()
            if let repeated = next as? RepeatResponse {
                switch repeated {
                case let .repeat(value, count: count):
                    if count > 1 {
                        outputs.insert(RepeatResponse.repeat(value, count: count - 1), at: 0)
                    }
                case .repeatInfinite:
                    outputs.insert(repeated, at: 0)
                }
            }
            return next
        }

        /// Replaces default implementation from protocol. All `NetworkService` functions should eventually end up in
        /// this
        /// version of `start`.
        /// Delay and repeat are handled here.
        public func start(_: URLRequest) async -> Result<Data, Failure> {
            let next: MockOutput
            do {
                next = try queue()
            } catch {
                return .failure(Failure.unknown(error as NSError))
            }
            switch delay {
            case .infinite:
                return await Task {
                    try await scheduler.sleep(for: .seconds(.max))
                    return try next.output.get()
                }
                .result.mapToNetworkError()
            case .seconds:
                return await Task {
                    try await scheduler.sleep(for: .seconds(delay.interval))
                    return try next.output.get()
                }
                .result.mapToNetworkError()
            case .none:
                // Setting the delay publisher to zero seconds was buggy.
                // It works better to not add delay for `none`.
                return next.output
            }
        }

        public enum Errors: Error, Equatable {
            case noOutputQueued
        }
    }
#endif

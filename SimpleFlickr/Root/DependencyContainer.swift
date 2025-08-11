//
//  DependencyContainer.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

/// A lightweight dependency injection container for registering and resolving services by type.
@Observable
@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]
    
    /// Registers a service instance for the specified type.
    ///
    /// - Parameters:
    ///   - type: The type of the service to register.
    ///   - service: The service instance to register.
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    /// Registers a service instance for the specified type using a factory closure.
    ///
    /// - Parameters:
    ///   - type: The type of the service to register.
    ///   - service: A closure that returns the service instance to register.
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    /// Resolves and returns the service instance registered for the specified type.
    ///
    /// - Parameter type: The type of the service to resolve.
    /// - Returns: The service instance registered for the specified type, or `nil` if no service is registered.
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}

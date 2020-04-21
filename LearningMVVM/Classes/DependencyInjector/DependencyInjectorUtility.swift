//
//  DependencyInjectorUtility.swift
//  LearningMVVM
//
//  Created by Aniruddha Das on 11/04/20.
//  Copyright © 2020 Aniruddha Das. All rights reserved.
//

import Foundation

//MARK: DEPENDENCY INJECTION - SERVICE LOCATOR PATTERN USING CONTAINER, RESOLVER and SERVICE FACTORY.

protocol Resolver {
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
}

public final class Container: Resolver {
    var factories: [AnyServiceFactory]

    init() {
        self.factories = []
    }

    fileprivate init(factories: [AnyServiceFactory]) {
        self.factories = factories
    }

    // MARK: Register
    func register<T>(_ interface: T.Type, instance: T) {
        register(interface) { _ in instance }
    }
    
    func register<ServiceType>(_ type: ServiceType.Type, _ factory: @escaping (Resolver) -> ServiceType) {
        assert(!factories.contains(where: { $0.supports(type) }))

        let newFactory = BasicServiceFactory<ServiceType>(type, factory: { resolver in
            factory(resolver)
        })
        
        factories.append(AnyServiceFactory(newFactory))
    }

    // MARK: Resolver

    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }

    func factory<ServiceType>(for type: ServiceType.Type) -> () -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }

        return { factory.resolve(self) }
    }
}

protocol ServiceFactory {
    associatedtype ServiceType

    func resolve(_ resolver: Resolver) -> ServiceType
}

extension ServiceFactory {
    func supports<T>(_ type: T.Type) -> Bool {
        return type == ServiceType.self
    }
}

extension Resolver {
    func factory<ServiceType>(for type: ServiceType.Type) -> () -> ServiceType {
        return { self.resolve(type) }
    }
}

struct BasicServiceFactory<ServiceType>: ServiceFactory {
    private let factory: (Resolver) -> ServiceType

    init(_ type: ServiceType.Type, factory: @escaping (Resolver) -> ServiceType) {
        self.factory = factory
    }

    func resolve(_ resolver: Resolver) -> ServiceType {
        return factory(resolver)
    }
}

final class AnyServiceFactory {
    private let _resolve: (Resolver) -> Any
    private let _supports: (Any.Type) -> Bool

    init<T: ServiceFactory>(_ serviceFactory: T) {
        self._resolve = { resolver -> Any in
            serviceFactory.resolve(resolver)
        }
        self._supports = { $0 == T.ServiceType.self }
    }

    func resolve<ServiceType>(_ resolver: Resolver) -> ServiceType {
        return _resolve(resolver) as! ServiceType
    }

    func supports<ServiceType>(_ type: ServiceType.Type) -> Bool {
        return _supports(type)
    }
}

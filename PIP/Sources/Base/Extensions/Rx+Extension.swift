//
//  Rx+Extension.swift
//  PIP
//
//  Created by caishilin on 2024/5/29.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - StateRelay

@propertyWrapper
struct State<State> {
    public var wrappedValue: State {
        get {
            return projectedValue.value
        }
        set {
            projectedValue.accept(newValue)
        }
    }
    
    let projectedValue: BehaviorRelay<State>
    
    init(wrappedValue: State) {
        projectedValue = BehaviorRelay(value: wrappedValue)
    }
}

@propertyWrapper
struct LocalStorageState<State: Codable> {
    private let key: String
    public var wrappedValue: State {
        get {
            return projectedValue.value
        }
        set {
            projectedValue.accept(newValue)
            LocalStorage.save(newValue, forKey: key)
        }
    }
    
    let projectedValue: BehaviorRelay<State>
    
    init(wrappedValue: State, key: String) {
        self.key = key
        let defaultValue: State = LocalStorage.load(forKey: key) ?? wrappedValue
        projectedValue = BehaviorRelay(value: defaultValue)
    }
}

extension Observable {
    func asyncBind(onNext: @escaping (Element) -> Void, on queue: DispatchQueue = .main) -> Disposable {
        bind(onNext: { element in
            queue.async {
                onNext(element)
            }
        })
    }
}

extension BehaviorRelay {
    func asyncBind(onNext: @escaping (Element) -> Void, on queue: DispatchQueue = .main) -> Disposable {
        bind(onNext: { element in
            queue.async {
                onNext(element)
            }
        })
    }
}

enum LocalStorage {
    static func save<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            logger.error("Failed to encode value for key: \(key)")
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func load<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}


// MARK: - EventRelay

@propertyWrapper
struct Event<Event> {
    public var wrappedValue: Event? { nil }
    
    func trigger(_ event: Event) {
        projectedValue.accept(event)
    }
    
    func trigger() where Event == Void {
        trigger(())
    }
    
    let projectedValue: PublishRelay<Event> = .init()
}

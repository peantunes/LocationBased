//
//  KeyValueStoreProviding.swift
//  LocationBased
//
//  Created by Pedro Antunes on 14/11/2023.
//

import Foundation

protocol KeyValueStoreProviding {
    func setValue(_ value: Any?, forKey key: String)
    func data(forKey key: String) -> Data?
}

protocol HasKeyValueStore {
    var keyValueStoreProvider: KeyValueStoreProviding { get }
}

class KeyValueStoreProvider: KeyValueStoreProviding {
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.lolados.Lister.Documents") ?? UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func data(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }
}

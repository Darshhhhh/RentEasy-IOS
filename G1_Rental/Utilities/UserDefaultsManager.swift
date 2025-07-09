//
//  UserDefaultsManager.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

class UserDefaultsManager {
    static var rememberMe: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.rememberMeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.rememberMeKey) }
    }
    static var savedEmail: String? {
        get { UserDefaults.standard.string(forKey: Constants.savedEmailKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.savedEmailKey) }
    }
    static var savedPassword: String? {
        get { UserDefaults.standard.string(forKey: Constants.savedPasswordKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.savedPasswordKey) }
    }
}

//
//  Config.swift
//  FinIQ
//
//  Environment config - switch via Xcode Scheme (Debug/Release)
//

import Foundation

enum Config {
    #if DEBUG
    static let baseURL = "http://localhost:8787"
    #else
    static let baseURL = "https://api.finiq.com"
    #endif
}
//
//  LocationBasedApp.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import SwiftUI

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if launchOptions?.keys.contains(.location) ?? false {
            print("location based change")
        } else {
            print("other reason to launch: \(launchOptions?.keys.map(\.rawValue) ?? [])")
        }
        return true
    }
}

@main
struct LocationBasedApp: App {
    // inject into SwiftUI life-cycle via adaptor !!!
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

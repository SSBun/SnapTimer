//
//  AppDelegate.swift
//  PIP
//
//  Created by caishilin on 2024/5/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabViewController()
        window?.makeKeyAndVisible()
        window?.tintColor = .systemGreen
        return true
    }
}

